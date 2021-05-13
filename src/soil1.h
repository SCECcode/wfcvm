c  include file soil1.h
c soil type info
        parameter (numsoil=5,nx2=4000,ny2=4000)
        common /soil/ rlatmax,rlatmin,rlonmax,rlonmin,nx,ny,
     1  isb(nx2,ny2),rdelx,rdely
