        program  utah_wf_basins

c Wasatch Front CVM.
c H. Magistrale 10/06
c
         include 'in.h'

         character(128) modelpath

         modelpath= TRIM('.')//achar(0)
         ecode = 0

c--display version-------------------------------------
         call wfcvm_version(version, ecode)
         if(ecode.ne.0)then
            write(*,*)' error retrieving version '
            goto 98
         endif
         write( 0, * )'SCEC WFCVM ',version

c--read points of interest file-------------------------
         call readpts(kerr)
         if(kerr.ne.0)then
            write(*,*)' error with point in file '
            go to 98
         endif

c--perform init-----------------------------------------
         call wfcvm_init(modelpath, ecode)
         if(ecode.eq.1)then
           write(*,*)' error with init '
           goto 98
         endif

c--perform query-----------------------------------------
         call wfcvm_query(nn,rlon,rlat,rdep,alpha,beta,rho,ecode)
         if(ecode.eq.1)then
           write(*,*)' error with query '
           goto 98
         endif

c---write out points and values-------------------
         call writepts(kerr)
         if(ecode.eq.1)then
           write(*,*)' error with point out file '
           goto 98
         endif
98       stop
         end

