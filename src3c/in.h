c  in.h   contains i-o stuff
      include 'params.h'
      common /wfoi/ rlat, rlon, rdep, alpha, beta, rho, nn, nnl
      real :: rlat(ibig), rlon(ibig), rdep(ibig), alpha(ibig),
     $  beta(ibig), rho(ibig)
      integer :: nn, nnl
