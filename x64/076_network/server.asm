### httpdito-386: small assembly HTTP server program for i386 Linux.
### It serves up files from the directory where you run it on port

        .equiv port_number, 8086

### To serve up your current directory via HTTP:
### $ gcc -m32 -nostdlib server.s -o server.bloated
### $ objcopy -S -R .note.gnu.build-id server.bloated server
### $ ./server &
### $ firefox http://localhost:8086/  # to see

### http://creativecommons.org/publicdomain/zero/1.0/

### To the extent possible under law, Kragen Javier Sitaker has waived all
### copyright and related or neighboring rights to Dercuano.  This work is
### published from Argentina.

### Gloriously filthy: defines only two subroutines; all variables are
### global.  Does not depend on the C libraries.  2060 bytes of
### executable built as above; about 1115 bytes of that is this code.

### Whoa.  Apparently this got featured on programming.reddit.com and
### Hacker News, and then I got like 30 000 hits on my web server.  Hi
### everybody!

### Performance is passable; on my laptop, it can push about 1.8
### gigabits per second of traffic, while Apache in Debian's default
### configuration hits about 2.5 Gbps.  On the same (8-core) machine,
### it can handle about 20000–30000 requests per second, according to
### ab.  But ab is probably the bottleneck here, and reports similar
### numbers for Apache.  ab also runs into unpredictable performance
### when you test with high concurrency, like 1000.  To even do that
### kind of testing successfully, you need to reconfigure your kernel
### to turn off syncookies (thanks for helping me with this,
### Humbedooh!):

### # sysctl net.ipv4.tcp_syncookies=0

### Rave reviews from the public:
### "The awesome thing about this link is the commenting. Its [sic] both 
###  detailed and relevant." --- [barbequeninja][0]  
### "Impressive, yet it has the portability of an elephant." 
### --- [ThatCrankyGuy][0]  
### "What the hell is wrong with this person!?" --- [jantelo][0]  
### "OMG all these macros. It looks more like Python then Assembly. Come
###  on, real men do not use macros." --- [meshko][1]  
### "yes, yes, and more yes! :)" --- [nullnullnull][0]  
### "Sounds like an exercise in sadomasochism" --- [speedisavirus][0]  
### "PoC's based on low-level concepts are the ones that make you
###  curious about everything from top to bottom. Even though assembly is the
###  least abstract and most esoteric of programming (some would argue
###  opposite) spaces, the program actually reveals itself quite quickly
###  knowing just a few tid-bits. This is how you get to see that even the
###  most low-level aspects of programming are quite accessible."
###  --- [knappador][1]
### "This is simultaneously elegant and dirty. The best kind of hack."
### --- [TheScriptKiddie][0]  
### "Neat little piece of performance art (pun intended)." --- [pmiller2][1]  
### "Err... Why?" --- [jonbonazza][0]  
### "God help his soul...." --- [Ravnerous][0]  

### "This is wrong in so many levels :(." --- [confiq][0]  
### "[Why?] 'Because we can.' Well, because he can. I'm not touching 
###  this with a 10 foot pole." --- [Ivoos001][0]  
### "Reading this was like reading a BASIC program with gosub/return." 
### --- [oldprogrammer][0]  
### "Assembly? What a loser! I've coded a transactional database using a
###  modified Babbage engine... it'll take queries in TCP, UDP AND Morse
###  code!" --- [Papa_Formosus][0]  
### "If it can't be done, someone will do it." --- [killchain][0]  
### "I look forward to debugging this code. /s" --- [anirudh4444][0]  
### "I personally think that using the Linux kernel's TCP/IP stack when
###  writing a 'bare metal' HTTP server is cheating." --- [kyz][0]  
### "I doubt this is too optimized for size, since there are obvious
###  tricks that it misses." --- [pbsd][1]  
### "Very cool I think. But cooler, Web Server on a FPGA, without CPU,
###  only VHDL <http://www.youtube.com/watch?v=7syu5EC1OWg>" 
###  --- [zw123456][1]  

### [0]: http://www.reddit.com/r/programming/comments/1swtuh/
### [1]: https://news.ycombinator.com/item?id=6908064

### XXX do we have a potential bug with a write to a blocking socket
### completing partially instead of fully because network buffers are
### full?


        

### http_server: this is the main program; at the end of this file,
### this macro will be invoked.  I'm writing it in this form in order
### to get freedom of presentation.

.macro http_server
        ## The basic structure is very simple: we listen on a socket,
        ## then loop, accepting a connection and spawning off a child
        ## to read a request and send a response for each connection.

        ## We store the socket file descriptor we're using in one
        ## register most of the time; in the parent, that's the
        ## listening socket, and in the children, that's the client
        ## connection.
        .equiv sock_reg, %ebp
        library_functions
syscall_fail:                   # placed above main for shorter jumps
        syscall_fail_handler
	.globl _start           # This is ld's default entry point.
        .weak _start       # So you can compile without -nostdlib too.
_start:
        .globl main
main:   setup_socket
        main_loop
.endm

### setup_socket: there’s little interesting to say here that’s not
### in, say, Beej’s Socket Guide.
.macro setup_socket
        open_socket
        do_so_reuseaddr
        do_bind
        do_listen
.endm

### 386 Linux provides all the socket system calls via a multiplexor
### called `socketcall`.
### socketcall is defined in net/socket.c, a two-argument
### system call whose second argument is a pointer to a vector of an
### arbitrary number of arguments.  include/linux/net.h lists the call
### numbers to pass to it.

.macro open_socket
        my socket_args, .long PF_INET, SOCK_STREAM, 0
        sys2 $__NR_socketcall, $SYS_SOCKET, $socket_args

        errloc_is socket()
	cmp $0, %eax
        jl syscall_fail
        mov %eax, sock_reg
.endm

.macro do_so_reuseaddr
        my true, .int 1
        my setsockopt_args, .long 0, SOL_SOCKET, SO_REUSEADDR, true, 4
        mov sock_reg, (setsockopt_args)
        sys2 $__NR_socketcall, $SYS_SETSOCKOPT, $setsockopt_args

        errloc_is setsockopt(SO_REUSEADDR)
        cmp $0, %eax
        jl syscall_fail
.endm

.macro do_bind
        mov sock_reg, (bind_args)
        sys2 $__NR_socketcall, $SYS_BIND, $bind_args
        my bind_args, .long 0, addr, sockaddr_in_size
        .data
addr:   .short AF_INET
        .byte port_number >> 8, port_number & 0xff
        .int 0                  # INADDR_ANY: 0.0.0.0
        .text

        errloc_is bind()
        cmp $0, %eax
        jl syscall_fail
.endm

.macro do_listen
        mov sock_reg, (listen_args)
        sys2 $__NR_socketcall, $SYS_LISTEN, $listen_args
        my listen_args, .long 0, 5 # 5 is the traditional max, and is enough.
        errloc_is listen()
        cmp $0, %eax
        jl syscall_fail
.endm

### So much for setup.  The main loop, running forever, spawns off a
### new child process for each incoming connection.

.macro main_loop
accept_loop:
        var clientsock # client socket FD, though mostly we use sock_reg
        do_accept
        reap_children
        do_fork               # After this is only child process code.
        ## Now we would like to try reading an HTTP request from the
        ## client.  So we need a buffer and a buffer pointer.  We
        ## reuse them later for sending the response.
        .bss
bufp:   .int 0
buf:    .fill bufsiz, 1, 0
        .text
        ## Note that this happens in the child process only, so the
        ## parent's sock_reg continues to be the listening socket.
        mov (clientsock), sock_reg
        set_timeout
        read_request
	jmp request_done
badreq: send_error    # weird error handler placement to shorten jumps
        jmp exit_child
request_done:
        clear_timeout
        decode_request
        send_response
exit_child:
        exit_successfully
.endm

.macro do_accept
        ### Now that we have our server port set up and listening, we
        ### can start accepting connections.
        mov sock_reg, (accept_args)
        sys2 $__NR_socketcall, $SYS_ACCEPT, $accept_args
        my accept_args, .long 0, sockaddr, sockaddr_size
        .bss
sockaddr:
        .fill sockaddr_in_size, 1, 0
        .text
        var sockaddr_size

        mov %eax, (clientsock)
        cmp $0, %eax            # On failure, complain but continue.
        jnl 1f
        errloc_is accept()
        call report_sys_error
        jmp accept_loop
1:
.endm

.macro reap_children
        ## Before we fork, we reap any zombie children, so they don't
        ## fill up the process table.  To limit how many they are, we
        ## maintain a counter of available connection slots, and when
        ## it hits zero, we wait to reap at least one zombie child
        ## before proceeding.
        my available_connections, .int 2048
1:      xor %edx, %edx
        cmpl $0, (available_connections)
        jz 2f
        mov $WNOHANG, %edx
2:      sys3 $__NR_waitpid, $0, $0, %edx
        cmp $0, %eax
        jz 1f              # WNOHANG and no children ready for reaping
        jl 2f              # if negative, report an error and proceed
        incl (available_connections) # We reaped a child.
        jmp 1b
2:      cmp $-ECHILD, %eax
        je 1f   # If no children at all, don't complain.  Be thankful.
        errloc_is waitpid()
        call report_sys_error
1:      
.endm

.macro do_fork
        ## The parent jumps right back to accept_loop, while the child
        ## proceeds.
        sys0 $__NR_fork
        cmp $0, %eax
        jg 1f                   # positive: we are the parent
        jz 2f                   # zero: we are the child
        errloc_is fork()        # negative: we are the parent and have an error
        call report_sys_error
1:      sys1 $__NR_close, (clientsock) # parent must relinquish per-connection socket
        decl (available_connections)
        jmp accept_loop
2:      
.endm

.macro library_functions

report_sys_error:
	neg %eax
        push %eax       # save errno on entry in case write() fucks up
        do_strlen (errs) # result is in %ecx, but do3 macro clobbers that
        mov %ecx, %eax
        sys3 $__NR_write, $2, (errs), %eax
        my separator_string, .ascii ": look up in /usr/include/asm-generic/errno.h and /usr/include/asm-generic/errno-base.h errno="
        my newline_string, .ascii "\n"
        sys3 $__NR_write, $2, $separator_string, $(newline_string - separator_string)
        pop %eax
        call print_positive_int_stderr
        sys3 $__NR_write, $2, $newline_string, $1
        ret

print_positive_int_stderr:
        ## Input unsigned integer is in %eax.
        xor %edx, %edx
        mov $10, %ecx           # yes, wasteful to do this each time
        idiv %ecx               # remainder in %edx, quotient in %eax
        test %eax, %eax
        jz 1f
        push %eax
        push %edx
        call print_positive_int_stderr
        pop %edx
        pop %eax
1:      add $'0, %dl            # convert digit to ASCII
        var digit
        mov %dl, (digit)        # store in memory so we can write(2)
        sys3 $__NR_write, $2, $digit, $1
        ret
.endm

### This alarm will kill the child process, and thus the connection,
### after 32 seconds if not canceled.  This way we ensure that if
### someone opens a connection to us and then unplugs their laptop,
### they aren't tying up a child process indefinitely.  We probably
### really ought to send an HTTP 408 error in this case, but it's so
### unlikely to happen in practice (except defending against DoS) that
### I don't care.
.macro set_timeout
        sys1 $__NR_alarm, $32
.endm

### And this macro, invoked after we've received the entire request
### and are planning to respond, cancels the timeout.  Once we're
### sending data, TCP will eventually kill the connection if that data
### is not acknowledged.
.macro clear_timeout
        sys1 $__NR_alarm, $0
.endm

.macro read_request
        movl $0, (bufp)
keep_reading:   
        read_into_remaining_space
        fail_if_read_error
        keep_reading_if_not_done
.endm

.macro read_into_remaining_space
        mov (bufp), %eax
        mov $bufsiz-1, %edx
        sub %eax, %edx          # calculate remaining space
        add $buf, %eax          # and address in buffer

        sys3 $__NR_read, sock_reg, %eax, %edx
.endm

.macro fail_if_read_error
        errloc_is read()
        cmp $0, %eax
        jnl 2f
        call report_sys_error
        sys1 $__NR_close, sock_reg
        jmp accept_loop
2:
.endm

.macro keep_reading_if_not_done
        je 1f                   # EOF (0) should terminate the request.
        add (bufp), %eax        # XXX can't we add to memory?  This is CISC!
        mov %eax, (bufp)
        keep_reading_if_no_crlfcrlf
1:                              # done reading the request
.endm

.macro keep_reading_if_no_crlfcrlf
        mov $('\r | '\n << 8 | '\r << 16 | '\n << 24), %eax # note big-endian
        mov $buf, %esi
        mov (bufp), %ecx
        sub $3, %ecx
        jle keep_reading        # haven't read enough to see a CRLFCRLF
2:      cmp (%esi), %eax        # Unaligned reads FTW!
        je 3f
        inc %esi
        loop 2b
        jmp keep_reading
3:      
.endm

.macro decode_request
        find_request_path
        unescape_request_path   # "%2e" → "." and stuff like that
        ensure_request_path_is_safe # prevent path traversal vulnerabilities
.endm

### We assume that the request path is 5 bytes into the buffer and
### that the request is a GET.
.macro find_request_path
        cmp $5, (bufp)
        jl badreq               # Fail if request is too short to have a path.
        xor %eax, %eax
        mov $' , %al
        ## cld # not necessary because DF is 0 at startup and we never set it
        mov $buf+5, %edi
        mov (bufp), %ecx
        repne scasb
        test %ecx, %ecx
        jz badreq
        movb $0, -1(%edi)       # NUL-terminate the path.

        .equiv path, buf+5
.endm

.macro unescape_request_path
        mov $path, %esi
        mov %esi, %edi
1:      lodsb
        cmp $'%, %al
        jne 2f                  # skip decoding if not %
        unescape_one_output_byte
2:      stosb                   # Decoded or no, we have the char.
        test %al, %al
        jnz 1b                  # Terminate loop if we copied a \0.
.endm

.macro unescape_one_output_byte
        mov $2, %ecx            # 2 hex digits to decode
        xor %edx, %edx          # initial value: 0
        xor %eax, %eax
3:      lodsb
        decode_one_hex_digit
        add %eax, %edx
        loop 3b
        mov %edx, %eax
.endm

.macro decode_one_hex_digit
        shl $4, %edx
        sub $'0, %al            # Is it a decimal digit?
        jl badreq2
        cmp $9, %al
        jle 5f

        ## If it wasn’t a digit, maybe a capital A-F?
4:      sub $('A-'0-10), %al    # so that 'A' becomes 10
        cmp $10, %al
        jl badreq2              # fail decode if '9' < c < 'A'
        cmp $15, %al
        jle 5f

        ## Maybe lowercase a-f?
        sub $('a-'A), %al
        cmp $10, %al
        jl badreq2              # fail if 'F' < c < 'a'
        cmp $15, %al
        jg badreq2              # if c > 'f' then we fail
5:
.endm

### OK, now we have decoded our ASCIZ path.  Now we could open() it.

### First, though, we need to make sure it’s "safe", preventing "path
### traversal vulnerabilities".
.macro ensure_request_path_is_safe
        ## Specifically, we want to make sure
        ## people can’t request "/etc/passwd", "../../../etc/passwd",
        ## ".htpasswd", and so on.  On Windows NT, there are maybe
        ## other things to worry about, like "CON", but on Linux it
        ## should be sufficient to ensure that it doesn’t begin with
        ## '.' or '/' and doesn’t contain "/.".  In the end, though,
        ## it depends on the filesystem more than the OS.
        mov (path), %al
        cmp $'., %al
        je badreq2
        cmp $'/, %al
        je badreq2

        badreq_if_slashdot_in_path
.endm

.macro badreq_if_slashdot_in_path       
        mov $('/ | '. << 8), %dx
        testb $0xff, (path)
        jz 2f                   # empty path cannot contain "/."
        mov $path, %esi
1:      testb $0xff, 1(%esi)
        jz 2f                   # found NUL termination; done
        cmp (%esi), %dx
        je badreq2
        inc %esi
        jmp 1b
        badreq_trampoline
2:      
.endm

### This is a silly little macro whose purpose is to save bytes by
### letting us use short (2-byte) conditional jumps to badreq, instead
### of the 6-byte form introduced on the 386.
.macro badreq_trampoline
badreq2:
        jmp badreq
.endm


### Open a file, now that we know it's safe, and, if successful, send
### it to the client.
.macro send_response
        var file                # file descriptor
        open_file
        send_header
        send_file
        sys1 $__NR_close, (file)
        sys1 $__NR_close, sock_reg
.endm

.macro open_file
        sys2 $__NR_open, $path, $O_RDONLY
        cmp $0, %eax
        jl badreq2
        mov %eax, (file)
.endm

.macro send_header
        ## We probably should at least see if it’s HTML first before
        ## we send it, to set the MIME-type.

        .data
header_200_base:
        .ascii "HTTP/1.0 200 OK\r\nContent-Type: "
text_plain:
        .ascii "text/plain; charset=utf-8"
text_plain_end:
text_css:
        .ascii "text/css; charset=utf-8"
text_css_end:
application_pdf:
        .ascii "application/pdf"
application_pdf_end:    
        .text
        sys3 $__NR_write, sock_reg, $header_200_base, $(text_plain - header_200_base)
        ## As a matter of policy, we ignore failures writing to the client.
	
        ## Send the correct MIME-type:
        if_not_ends_with_dot_html_go_to path, 1f
        sys3 $__NR_write, sock_reg, $text_html, $(text_html_end - text_html)
        jmp 2f
1:      if_not_ends_with_dot_css_go_to path, 4f
	sys3 $__NR_write, sock_reg, $text_css, $(text_css_end - text_css)
        jmp 2f
4:      if_not_ends_with_dot_pdf_go_to path, 3f
        sys3 $__NR_write, sock_reg, $application_pdf, $(application_pdf_end - application_pdf)
        jmp 2f
3:      sys3 $__NR_write, sock_reg, $text_plain, $(text_plain_end - text_plain)
        my crlfcrlf, .asciz "\r\n\r\n"
2:      sys3 $__NR_write, sock_reg, $crlfcrlf, $4
.endm

### Check whether the string at addr ends with ".html"; if not, go to label.
### Clobbers %esi, %edi, %eax, %ecx, and the direction flag.
.macro if_not_ends_with_dot_html_go_to addr, label
        .equiv dot_html_len, 5
        lea \addr, %edi
        xor %eax, %eax
        lea -1(%eax), %ecx
        ## cld # not necessary; see comment on other cld.
        repne scasb
        ## At this point %ecx has -strlen(addr)-2 in it and %edi has
        ## been stepped past the NUL byte at the end of the string.
        ## We want to know if the string is too short to contain
        ## ".html".
        cmp $(-dot_html_len-2), %ecx
        jg \label

        ## If not, compare its trailing bytes to ".html".
        cmpl $('h | 't << 8 | 'm << 16 | 'l << 24), -5(%edi)
        jne \label
        cmpb $('.), -6(%edi)
        jne \label
.endm

.macro if_not_ends_with_dot_css_go_to addr, label
        .equiv dot_css_len, 4
        lea \addr, %edi
        xor %eax, %eax
        lea -1(%eax), %ecx
        repne scasb
        cmp $(-dot_css_len-2), %ecx
        jg \label
        cmpl $('. | 'c << 8 | 's << 16 | 's << 24), -5(%edi)
        jne \label
.endm

.macro if_not_ends_with_dot_pdf_go_to addr, label
        .equiv dot_pdf_len, 4
        lea \addr, %edi
        xor %eax, %eax
        lea -1(%eax), %ecx
        repne scasb
        cmp $(-dot_pdf_len-2), %ecx
        jg \label
        cmpl $('. | 'p << 8 | 'd << 16 | 'f << 24), -5(%edi)
        jne \label
.endm
	
.macro send_file
        ## Now copy each bufferful of file out to the client.
1:      sys3 $__NR_read, (file), $buf, $bufsiz
        cmp $0, %eax
        jle 2f                  # Done on EOF or read error
        var readsize
        mov %eax, (readsize)
        sys3 $__NR_write, sock_reg, $buf, (readsize)
        jmp 1b
2:
.endm

.macro syscall_fail_handler
	## Syscall failure handling in setup.
        call report_sys_error
        sys1 $__NR_exit, $1
.endm

.macro send_error
        .data
err404: .ascii "HTTP/1.0 404 Not found\r\n" # not asciz, ascii
        .ascii "Content-type: "
text_html:                      # labeled because we use this elsewhere
        .ascii "text/html; charset=utf-8"
text_html_end:
        .ascii "\r\n\r\n"
        .ascii "<title>404 not found</title>\n"
        .ascii "<p>Actually, there was just some arbitrary error.  Maybe\n"
        .ascii "your request was bad.\n"
err404_end:
        .text
        sys3 $__NR_write, sock_reg, $err404, $(err404_end - err404)
        sys1 $__NR_close, sock_reg
.endm

.macro exit_successfully
        ## For use in child processes.
        sys1 $__NR_exit, $0
.endm

### Low-level system interface:

	# We can’t #include <sys/socket.h> because it tries to define
	# a bunch of C structures.  So here are the things we use from
	# it.
        .equiv SOCK_STREAM, 1   # /usr/include/i386-linux-gnu/bits/socket.h:42
        .equiv PF_INET, 2       # /usr/include/i386-linux-gnu/bits/socket.h:78
	.equiv AF_INET, PF_INET # /usr/include/i386-linux-gnu/bits/socket.h:121 I think
	.equiv SOL_SOCKET, 1    # /usr/include/asm-generic/socket.h:7
        .equiv SO_REUSEADDR, 2  # /usr/include/asm-generic/socket.h:10
        .equiv O_RDONLY, 0      # /usr/include/asm-generic/fcntl.h:19
        .equiv sockaddr_in_size, 16  # ??? I got it from fucking strace.

        ## System call numbers, which I originally mostly found in dietlibc
        .equiv __NR_exit, 1     # linux/arch/x86/include/asm/unistd_32.h:9
        .equiv __NR_fork, 2
        .equiv __NR_read, 3
        .equiv __NR_write, 4
        .equiv __NR_open, 5
        .equiv __NR_close, 6
        .equiv __NR_waitpid, 7
        .equiv __NR_alarm, 27
        .equiv __NR_socketcall, 102

        ## socketcall takes these identifiers for which call you want:
        .equiv SYS_SOCKET, 1    # linux/include/linux/net.h:26
        .equiv SYS_BIND, 2
        .equiv SYS_LISTEN, 4
        .equiv SYS_ACCEPT, 5
        .equiv SYS_SETSOCKOPT, 14

        ## waitpid takes this option to tell it to reap zombie
        ## children without waiting, which makes you think that maybe
        ## they could have found a better fucking name for the system
        ## call, but it's too late now.
        .equiv WNOHANG, 1       # diet/sys/wait.h:9

        ## Generally we don't care about specific errno values (we
        ## leave that up to the user), except when waitpid gives us
        ## ECHILD.
        .equiv ECHILD, 10       # I got this from strace.

        # Another arbitrary parameter:
        .equiv bufsiz, 1024     # plenty big enough for an HTTP GET request
	
        ## There are also a lot of variables.  Because we don’t have
        ## any recursion (or for that matter any functions), we can
        ## simply allocate them all statically, which simplifies
        ## things a lot.  But we still have to allocate them, which is
        ## simpler to do with a macro like this:
.macro my var, contents:vararg
        .data
\var:   \contents
        .previous
.endm
        ## But some variables don't need to be in the .data segment,
        ## because they're initially zero.  We can put them in .bss
        ## and get a smaller executable.
.macro var var
        .bss
\var:   .int 0
        .previous
.endm

        # The other thing we spend a lot of code doing is handling
        # errors.  When we bail out with an error, we first print the
        # string pointed to by the variable `errs`:
        var errs

        # So here’s a macro to set that.
.macro errloc_is description
        my errloc_\@, .asciz "\description"
        movl $errloc_\@, (errs)
.endm

### System calls with different numbers of arguments.
### `be x, y` is a macro that does `mov x, y` or equivalent.
.macro sys3 call_no, a, b, c
        be \c, %edx
        sys2 \call_no, \a, \b
.endm

.macro sys2 call_no, a, b
        be \b, %ecx
        sys1 \call_no, \a
.endm

.macro sys1 call_no, a
        be \a, %ebx
        sys0 \call_no
.endm

.macro sys0 call_no
        be \call_no, %eax
        ## There's a new, faster instruction for system calls, but I
        ## don't know how to use it yet.
        int $0x80
.endm

### Set dest = src.  Usually just `mov src, dest`, but sometimes
### there's a shorter way.
.macro be src, dest
        .ifnc \src,\dest
	.ifc \src,$0
        xor \dest,\dest
        .else
        .ifc \src,$1
        xor \dest,\dest
        inc \dest
        .else
        .ifc \src,$2
        xor \dest,\dest
        inc \dest
        inc \dest
        .else
	mov \src, \dest
        .endif
        .endif
        .endif
        .endif
.endm

### This macro leaves the number of nonzero bytes in the asciz string at
### addr in %ecx, clobbering %eax and %edi in the process.
.macro do_strlen addr
        mov \addr, %edi
        xor %eax, %eax
        lea -1(%eax), %ecx      # save a byte over xor/dec
        ## cld # not necessary; see comment on other cld
        repne scasb
        not %ecx
        dec %ecx
.endm

### At long last, here is the macro invocation that is our program:
        http_server

### A note about dietlibc:

### I was building this with dietlibc for a while, which was easier,
### but I eventually opted out of that to reduce overhead even
### further.  The Debian default dietlibc configuration adds around a
### kilobyte of overhead, which is totally reasonable.  But Fefe
### points out that you can configure dietlibc to eliminate most of
### its overhead!  He built a binary is 2080 bytes when the default
### one was 3140 bytes; note that this is only 112 bytes more than I
### got it down to by removing dietlibc.  You just have to comment out
### these things in dietfeatures.h:

### - WANT_TLS
### - WANT_THREADSAFE
### - WANT_SYSENTER (I think I'm already not using sysenter)
### - WANT_GNU_STARTUP_BLOAT
### - WANT_VALGRIND_SUPPORT
### - WANT_SSP

### Problems with `be` macro:

### * .equiv defines a symbol, not a textual replacement like #define.
###   Consequently sys1 $__NR_exit is not the same as sys1 $1, even
###   though __NR_exit is 1, and so we end up with an unreasonably
###   long instruction sequence:

        ## 080484bc <exit_child>:
        ##  80484bc:	31 db                	xor    %ebx,%ebx
        ##  80484be:	b8 01 00 00 00       	mov    $0x1,%eax
        ##  80484c3:	cd 80                	int    $0x80

### * In many cases we know what the value in some other register is,
###   but we don't use it.  For example:

 ## 804845b:	ba 04 00 00 00       	mov    $0x4,%edx
 ## 8048460:	b9 b0 96 04 08       	mov    $0x80496b0,%ecx
 ## 8048465:	89 eb                	mov    %ebp,%ebx
 ## 8048467:	b8 04 00 00 00       	mov    $0x4,%eax
 ## 804846c:	cd 80                	int    $0x80
        
###   The second 04 00 00 00 is totally gratuitous; moving %edx to
###   %eax would have worked fine, and that would be two bytes.

### Hmm, can I maybe shrink things a bit more by using writev() or the
### manual equivalent?  In report_sys_error and send_header there are
### things that use them.
