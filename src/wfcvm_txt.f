! ASCII I/O for SCEC CVM

      subroutine readpts( kerr )
      implicit none
      include 'in.h'
      integer :: kerr, i
c      write( 0, '(a)' ) 'Utah Geological Survey Community Velocity Model'
      read( *, * ) nn
      if ( nn > ibig ) then
         print *, 'Error: nn greater than ibig', nn, ibig
         stop
      end if
      do i = 1, nn
        read( *, * ) rlon(i), rlat(i), rdep(i)
        if( rdep(i) .lt. 0 ) write( 0, * )
     $    'Error: degative depth', i, rlon(i), rlat(i), rdep(i)
        if(rlon(i)/=rlon(i).or.rlat(i)/=rlat(i).or.rdep(i)/=rdep(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
        if( rdep(i) .lt. rdepmin ) rdep(i) = rdepmin
      end do
      kerr = 0
      end

      subroutine writepts( kerr )
      implicit none
      include 'in.h'
      integer :: kerr, i
      real :: rl
      do i = 1, nn
        if(rho(i)/=rho(i).or.alpha(i)/=alpha(i).or.beta(i)/=beta(i))
     $    write( 0, * ) 'Error: NaN', i, rlon(i), rlat(i), rdep(i)
        rl = rlon(i)
        write( *, '(f8.5,1x,f10.5,1x,f9.2,1x,f8.1,1x,f8.1,1x,f8.1)' )
     $    rlon(i), rlat(i), rdep(i), alpha(i), beta(i), rho(i)
      end do
      kerr = 0
      end

