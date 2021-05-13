c regional.h
c --  regional model info---------------------------
c  nregll = number points per layer of regional model
c  nregv  = total number P velocities in regional model
c         = nreglat*nreglon*nregly
c  nregly = number layers in regional model
         parameter(nreglat=110,nreglon=45,nregly=26,nregv=128700)
         common /wfregion/regvep(nregly,nreglon,nreglat),
     1   regves(nregly,nreglon,nreglat),
     1   reglat(nreglat),reglon(nreglon),reglay(nregly),reg1dv(nregly)
