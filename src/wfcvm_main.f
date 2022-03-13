        program  utah_wf_basins

c Wasatch Front CVM.
c H. Magistrale 10/06
c
         include 'in.h'

         character(128) modelpath
         character(128) str1
         character(128) datapath

         icount = iargc()
         if ( icount.eq.1 ) then
           call getarg(0, str1)
           call getarg(1, datapath)
           modelpath= TRIM(datapath)//achar(0)
         else
           modelpath= TRIM('.')//achar(0)
         endif

c        write(0,*)'modelpath ',modelpath

         ecode = 0

c--display version-------------------------------------
c         call wfcvm_version(version, ecode)
c         if(ecode.ne.0)then
c            write(*,*)' error retrieving version '
c            goto 98
c         endif
c         write( 0, * )'SCEC WFCVM ',version

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

