         subroutine wfcvm_init(modeldir, ecode)
         character(128) modeldir
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1

         rpath=modeldir(1:128)
         loc1= index(rpath,achar(0))-1
         ecode=0

c--read stratigraphic surfaces--------------------------
         call wfreadsurf(kerr)
         if(kerr.eq.1)then
         write(*,*)' error with strat files '
         go to 198
         endif
c        write(*,*) ' done with wfreadsurf'
c--read borehole data-----------------------------------
         call wfreadhole(kerr)
         if(kerr.eq.1)then 
         write(*,*)' error with borehole file '
         go to 198
         endif  
c        write(*,*) ' done with wfreadhole'
c--read generic borehole profiles-----------------------
         call wfreadgene(kerr)
         if(kerr.eq.1)then
         write(*,*)' error with geotech generic file '
         go to 198
         endif
c        write(*,*) ' done with wfreadgene'
c--read background crustal model------------------------
         call wfreadreg(kerr)
         if(kerr.eq.1)then
         write(*,*)' error with regional model file '
         go to 198
         endif
c        write(*,*) ' done with wfreadreg'
c--read soil types--------------------------------------
         call wfreadsoil(kerr)
         if(kerr.eq.1)then
         write(*,*)' error with soil type file '
         go to 198
         endif
c        write(*,*) ' done with wfreadsoil'
 198     ecode=kerr
         return
         end

c Null terminated version id.
c The 'str' argument must be 64 bytes in size
         subroutine cvms_version(str, ecode)
         character(64) str

         include 'version.h'
         str=TRIM(versionid)//achar(0)
         ecode=0
         return
         end
            
c WFCVM Query
         subroutine wfcvm_query(nn,rlon,rlat,rdep,alpha,beta,rho,ecode)
         dimension rlon(nn),rlat(nn),rdep(nn),alpha(nn),beta(nn),rho(nn)

c Wasatch Front CVM.
c H. Magistrale 10/06
c
         include 'params.h'
         include 'surface.h'
         include 'surfaced.h'
         include 'rkinfo.h'
         include 'number.h'
         include 'genpro.h'
         include 'borehole.h'

c PES 2011/07/21
         common /wfsuboi/inout(ibig)
         common/filestuff/rpath,fname,loc1
         dimension rsuqus(ibig,isurmx)

c--some constants---------------------------------------
         rd2rad=3.141593/180.
         rckval=5000000.
         ecode = 0

c PES 2011/07/21 check that nn is less than ibig
      if ( nn .gt. ibig ) then
        ecode = 1
        goto 98
      endif
  
c PES 2011/07/021 convert depth meters to feet
      do i = 1, nn
        rdep(i) = rdep(i) * 3.2808399
        if( rdep(i) .lt. rdepmin ) rdep(i) = rdepmin
      end do

c PES 2011/02/04 moved readers to init subroutine

c-------------------------------------------------------
c start main loop
c-------------------------------------------------------
         do 800 l0=1,nn
         iregfl=0
c--screen points for within or without surface area----
         if(rlat(l0).gt.42.0)goto 980
         if(rlat(l0).lt.33.75)goto 980
         if(rlon(l0).lt.-112.699997)goto 980
         if(rlon(l0).gt.-111.5)goto 980
c--number of reference surfaces
         inct = 3
c---find appropriate surface depths-------------------
         do 600 i9=1,inct
         i=i9
c---find valid surfaces-------------------------------
         do 813 l3=1,nlasur(i)-1
         if(rlat(l0).le.rlasur(i,l3).and.rlat(l0).gt.rlasur(i,l3+1))then
         do 824 l4=1,nlosur(i)-1
         if(rlon(l0).gt.rlosur(i,l4).and.rlon(l0).le.rlosur(i,l4+1))then
         rrt=(rlon(l0)-rlosur(i,l4))/(rlosur(i,l4+1)-rlosur(i,l4))
         rru=(rlat(l0)-rlasur(i,l3+1))/(rlasur(i,l3)-rlasur(i,l3+1))
c--note rsuval indexes are (surface number, long, lat)------
         rsuqus(l0,i9)=((1-rrt)*(1-rru)*rsuval(i,l4,l3+1))+(rrt*(1-rru)*
     1       rsuval(i,l4+1,l3+1))+(rrt*rru*rsuval(i,l4+1,l3))+((1-rrt)*
     2       rru*rsuval(i,l4,l3))
         go to 600
          endif
824        continue
          endif
813      continue
600      continue
c---which surface is above and below---------------
         rchk=rckval
         rchk2=rckval
         rshal=rckval
         iupflag=0
         iup=0
         idn=0
         ishal=0
         do 142 i8=1,inct
         rdelt=abs(rdep(l0)-rsuqus(l0,i8))
         rdelt2=abs(rsuqus(l0,i8)-rdep(l0))
         if(rdelt.lt.rchk.and.rsuqus(l0,i8).le.rdep(l0))then
          rchk=rdelt
          iup=i8
          endif
         if(rdelt2.le.rchk2.and.rdep(l0).lt.rsuqus(l0,i8))then
          rchk2=rdelt2
          idn=i8
          endif
142      continue
c -- diagnostics
c -- If you uncomment the following 6 lines and recompile, the program
c    will write the R depths (here variables rt111, rt222, and rt333)
c    to a file called 'fort.99'.  It also includes the lat, lon, and
c    depth (rd111), of the point, and the surface above (iup) and below
c    (idn) the point.
c           rt111=rsuqus(l0,1)/3.28084
c           rt222=rsuqus(l0,2)/3.28084
c           rt333=rsuqus(l0,3)/3.28084
c           rd111=rdep(l0)/3.2808399
c        write(99,1234)rlat(l0),rlon(l0),rd111,rt111,rt222,rt333,iup,idn
c1234    format(f12.6,5(1x,f12.6),1x,i2,i2)
c---in crystalline basement use background--------
c From the preceding code, iup = index of surface above point and
c idn = index of surface below point.  Surfaces are numbered from
c bottom to top, i.e., 1 = R3, 2 = R2, 3 = R1 (see surfaced.h). --JCP
c   here under basement
         if(iup.eq.1)go to 980 
c   here all surfaces zero
         if(rsuqus(l0,1).le.0..and.rsuqus(l0,2).le.0..and.rsuqus(l0,3)
     1   .le.0.)go to 980
c---assign reference surface parameters----------
c   For points located within basins, assign reference surface 
c   parameters needed for calculating alpha from Faust's relation.
c   The constants, rkall, are both basin- and surface-specific and
c   are assigned in the subroutine getkay.  Other parameters are
c   surface-specific only and are assigned in data statements in
c   surfaced.f.  The rkall values for R2 and R3 were calibrated from
c   sonic log data.  --JCP
c
c---assign rkall values---------------------------
         call getkay(rlat(l0),rlon(l0),iup,rkall)
c   here between surfaces
         if(iup.ne.0)then
           ra1=rage(iup)
           ra2=rage(idn)
           rk1=rkall(iup)
           rk2=rkall(idn)
           rf1=rfacs(iup)
           rf2=rfacs(idn)
           rd01=rsuqus(l0,iup)
           rd02=rsuqus(l0,idn)
          else
c   no surface above - assign surface age
           ra1=ragesur
           ra2=rage(idn)
           rk1=rkall(idn)
           rk2=rkall(idn)
           rf1=rfacs(idn)
           rf2=rfacs(idn)
           rd01=0.
           rd02=rsuqus(l0,idn)
         endif
c---calc scale factor-----------------------------
         rscal=(rdep(l0)-rd01)/(rd02-rd01)
c---scale sed age, constant, exponent-------------
         rtage=(rscal*ra2)+((1.-rscal)*ra1)
         rk=(rscal*rk2)+((1.-rscal)*rk1)
         rfac=(rscal*rf2)+((1.-rscal)*rf1)
         rtdep=rdep(l0)
c---find alpha in ft/s from Faust relation--------
c   The alpha (Vp) for points above R2 will be replaced later.  --JCP
         if(rtdep.eq.0.)rtdep=3.28084
         alpha(l0)=rk*(rtdep**rfac)*(rtage**rfac)
c---convert alpha to m/s--------------------------
         alpha(l0)=alpha(l0)*0.30480
c--------------------------------------------------
c---version 3c change here-------------------------
c
c   above R1, replacing Faust Vp with average from sonic logs
c   average smooth, 2 line segments
          if(iup.eq.0.and.idn.eq.3)then
           if(rdep(l0)/3.28084.le.368.)then
           alpha(l0)=1510.+(1.277*(rdep(l0)/3.28084))
           else
           alpha(l0)=1980.+(0.633*((rdep(l0)/3.28084)-368.))
           endif
          endif
c
c   above R2 and below R1, replacing Vp from ragged average curve of
c   idgen=17 with smooth fit, two line segments
         if(iup.eq.3.and.idn.eq.2)then
          if(rdep(l0)/3.28084.le.800.)then
           alpha(l0)=1825.+(0.631*(rdep(l0)/3.28084))
           else
           alpha(l0)=2330.+(1.338*((rdep(l0)/3.28084)-800.))
           endif
          endif
c
c---end version 3c change-------------------------
c   have new Vp in m/s
c-------------------------------------------------
c
c---define rho------------------------------------
c   using so cal version 4 linear relation
          rho(l0)=1865.+(.1579*alpha(l0))
c---define beta-----------------------------------
         sigma=0.40
         if(rho(l0).ge.2060.)sigma=.40-((rho(l0)-2060.)*.00034091)
         if(rho(l0).gt.2500.)sigma=0.25
         rsqfac=sqrt((1.-sigma)/(.5-sigma))
         beta(l0)=alpha(l0)/rsqfac
c-------------------------------------------------
c---geotech info----------------------------------
c   are above R1 or R2 in a basin, look up soil and holes
c   here above R1
         ifs=0
         if(iup.eq.0.and.idn.eq.3)then
          call wfgetsoil(rlat(l0),rlon(l0),isoilt,idgens)
          if(rdep(l0).le.(rmxdep(idgens)*3.2808399))ifs=1
          call wfnearhole(rlat(l0),rlon(l0),isoilt)
c---define geotech beta---------------------------
          call wfaddtopp(rdep(l0),beta(l0),idgens,ifs,beta2,rsuqus(l0,3))
          beta(l0)=beta2
c---define alpha back from beta-------------------
c   using Castagna et al. 1985 'mudline' as given in Brocher 2005
c   mudline works okay here, because it's all Vs controlled above R1
c         alphx=(1.16*beta(l0))+1360.
c   Version 3: empirical shift of intercept for mudline above R1
c   found by comparing predicted Vp to observed above R1
          alphx=(1.16*beta(l0))+1110.
          rhx=1865.+(.1579*alphx)
c---taper S based values into P based values------
           if(ifs.ne.1)then
           call taperp(rdep(l0),alpha(l0),rho(l0),alphx,rhx,alphy,rhy,
     1     rsuqus(l0,3),idgens)
           alpha(l0)=alphy
           rho(l0)=rhy
           else
           alpha(l0)=alphx
           rho(l0)=rhx
           endif
           go to 799
         endif
c---here above R2 and below R1--------------------
c---version 3c changes scattered in  here---------
c   dumping vp/vs ratio of version 3 and 3b
         if(iup.eq.3.and.idn.eq.2)then
          call wfgetsoil(rlat(l0),rlon(l0),isoilt,idgens)
c---skipping following lines of version 3+3b in version 3c--------
c   assign single deep generic profile , s (16) or p (17) wave based
c          if(rdep(l0).le.228.*3.2808399)then
c          idgens=16
c          else
c          idgens=17
c          endif
c
          if(rdep(l0).le.(rmxdep(idgens)*3.2808399))ifs=1
c  next line for version 3c
          if((rmxdep(idgens)*3.2808399).gt.rsuqus(l0,3))ifs=0
c---end skipping
          call wfnearhole(rlat(l0),rlon(l0),isoilt)
c---define geotech beta---------------------------
          call addtop3(rdep(l0),beta(l0),idgens,ifs,beta4)
          beta(l0)=beta4
c---define alpha back from beta-------------------
c   Version 3c: get the orginal Vp back if Vs was not changed by geotech
c   this neglects changes in sigma due to changes in Vs
          alphx=beta(l0)*rsqfac
          rhx=1865.+(.1579*alphx)
c---Version 3c: not using mudline between R1 and R2
c   using Castagna et al. 1985 'mudline' as given in Brocher 2005
c          alphx=(1.16*beta(l0))+1360.
c          rhx=1865.+(.1579*alphx)
c---following lines skipped in version 3c
c   using fixed Vp/Vs
c   this Vp/Vs ratio comes from comparing relatively shallow Vs in file
c   'all_generic12_hi' to deep Vp sonic logs in 'r1r2p.xy'
c         alphx=beta(l0)*1.643
c         rhx=1865.+(.1579*alphx)
c---end version 3c scattered changes----------------
c   note no taper here
          alpha(l0)=alphx
          rho(l0)=rhx
          go to 799
         endif
c---here above R3 and below R2--------------------
c   no geotech influence
         go to 799
c-------------------------------------------------
c---assign regional model-------------------------
c---Use Vp sonic log gradient up to 4 km depth and tomographic model
c---below 5 km depth.  From 4 to 5 km depth, taper quadratically
c---between these two models.
c---Tapering between models added by J.C. Pechmann, 10/6/2009
980      continue
c---if 4 km or above, use Vp sonic log gradient------
c   that Vp profile is read in readgene as profile number 18
c   so called rvsgen, but really Vp
         if(rdep(l0).le.4000.*3.2808399)then
         do 9888 nx=2,numptge2(18)
        if(rdep(l0).ge.rdepgen(18,nx-1).and.rdep(l0).lt.rdepgen(18,nx))
     1  then
         alpha(l0)=rvsgen(18,nx-1)
c    Set vp/vs ratio
c        beta(l0)=alpha(l0)/1.74
c    Version 3c:  install gradient of ratio in top 1.0 km
c    2.0 at surface, 1.74 at 1.0 km and below (as set in make_reg)
c    1.0 km is 3280.84 feet
         if(rdep(l0).gt.3280.84)then
              rvpvs=1.74
         else
              ratscal=(3280.84-rdep(l0))/3280.84
              rvpvs=(ratscal*2.0)+((1.-ratscal)*1.74)
         endif
         beta(l0)=alpha(l0)/rvpvs
c    End Version 3c change
c
         rho(l0)=1865.+(.1579*alpha(l0))
         go to 799 
         endif
9888     continue
         endif
c---if between 4 and 5 km, set Vp to a weighted average of Vp from the
c---sonic log gradient (alphasonic) and Vp from the tomographic model
c---(alphatomo).  Weighting factors give full weight to alphasonic at
c---4 km and full weight to alphatomo at 5 km, and vary quadratically
c---with depth in between.  Compute Vs in an analogous manner.
         if(rdep(l0).gt.4000.*3.2808399.and.rdep(l0).lt.5000.*3.2808399)
     1   then 
         do 9898 nx=2,numptge2(18)
        if(rdep(l0).ge.rdepgen(18,nx-1).and.rdep(l0).lt.rdepgen(18,nx))
     1  then
         alphasonic=rvsgen(18,nx-1)
c   use same vp/vs as set in make_reg
         betasonic=alphasonic/1.74
         endif
9898     continue
         call wfmakereg(rlat(l0),rlon(l0),rdep(l0),alp,bet,iregfl)
         alphatomo=alp
         betatomo=bet
         wtsonic=((5000.0-(rdep(l0)/3.2808399))/1000.0)**2
         wttomo=1.0-wtsonic
         alpha(l0)=(wtsonic*alphasonic) + (wttomo*alphatomo)
         beta(l0)=(wtsonic*betasonic) + (wttomo*betatomo)
         rho(l0)=1865.+(.1579*alpha(l0))
         go to 799
         endif
c---or use tomographic model----------------------
         call wfmakereg(rlat(l0),rlon(l0),rdep(l0),alp,bet,iregfl)
         alpha(l0)=alp
         beta(l0)=bet
         rho(l0)=1865.+(.1579*alpha(l0))
c
799      continue
c---check for deeper borehole info----------------
c   if below R1 and may have borehole data
         if(rdep(l0).le.rmaxbh.and.rdep(l0).gt.rsuqus(l0,2))then
          call nearhol2(rlat(l0),rlon(l0),l2flag)
c---get borehole beta but keep model Vp and rho---
          if(l2flag.ne.0)then
           call addtop2(rdep(l0),beta(l0),beta3)
           beta(l0)=beta3
          endif
         endif
c---clamp velocities here if wanted---------------
c   clamp for beta = 1.0 km/s
c         if(alpha(l0).lt.2414.)alpha(l0)=2414.
c         if(beta(l0).lt.1000.)beta(l0)=1000.
c   clamp for beta = 0.5 km/s
c         if(alpha(l0).lt.1225.)alpha(l0)=1225.
c         if(beta(l0).lt.500.)beta(l0)=500.
c-------------------------------------------------
c   end main loop
c-------------------------------------------------
800      continue
c PES 2011/02/04 convert depth feet to back to meters
      do i = 1, nn
        rdep(i) = rdep(i) / 3.2808399
      end do
 98      return
         end
cccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfreadsurf(kerr)
c---reads stratigraphic surfaces-------------------------
c---reads ascii lon, lat, z --------------------------

c PES 2011/07/21
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1

         include 'surface.h'
         character*4 asuf
         include 'names.h'
         asuf='.xyz'
         kerr=0
c---loop to read-------------------
         do 117 i=1,numsur
          fname=rpath(1:loc1)//'/'//aedname(i)//asuf
          open(16,file=fname,status='old',err=99)
           do 118 k=1,nlasur(i)
           do 118 j=1,nlosur(i)
       read(16,11188)rlosur(i,j),rlasur(i,k),rsuval(i,j,k)
11188  format(f12.6,f12.6,f12.6)
c---convert meters to feet----------
        rsuval(i,j,k)=rsuval(i,j,k)*3.28084
118       continue
         close(16)
117      continue
         go to 101
99       kerr=1
         write(*,*)' error reading file ', fname
101      return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfreadhole(kerr)

c PES 2011/07/21
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1

         include 'borehole.h'
         character fileib*10, isotyp2*6
c---file name assignment-----------
         fileib='boreholes3'
         fname=rpath(1:loc1)//'/'//fileib
         kerr=0
         rmaxbh=0.
c---read file----------------------
         open(15,file=fname,status='old',err=2978)
         do 8101 j=1, numbh
          read(15,401)numptbh(j),isotyp2,rlatbh(j),rlonbh(j)
401       format(t14,i3,t52,a6,t30,f9.6,1x,f11.6)
           if(isotyp2(3:3).eq.'1')isotype(j)=1
           if(isotyp2(3:3).eq.'2')isotype(j)=2
           if(isotyp2(3:3).eq.'3')isotype(j)=3
           if(isotyp2(2:3).eq.'af')isotype(j)=4
           if(isotyp2(2:2).eq.'g')isotype(j)=5
          rbhdmx(j)=numptbh(j)*1.*3.28084
c---find deepest borehole-----------
          if(rbhdmx(j).gt.rmaxbh)rmaxbh=rbhdmx(j)
c---read values---------------------
          do 8102 k=1, numptbh(j)
          read(15,402)rdepbh(j,k),rvs(j,k)
c---convert meters to feet----------
          rdepbh(j,k)=rdepbh(j,k)*3.28084
402       format(t5,f5.0,1x,f7.1)
8102      continue
8101     continue
         close(15)
          go to 2915
2978      kerr=1
2915      return
           end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
          subroutine wfreadreg(kerr)
c -- read regional model info---------------------------
c  nregll = number points per layer of regional model
c  nregv  = total number P velocities in regional model
c  nregly = number layers in regional model

         include 'params.h'
         include 'regional.h'

c PES 2011/07/21
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1
         common /wfsuboi/inout(ibig)

         kerr=0
         fname=rpath(1:loc1)//'/'//'reg_mod'
         open(19,file=fname,status='old',err=2999)
         do 1119 k=1,nreglat
          do 1119 j=1,nreglon
          read(19,1818)reglon(j),reglat(k)
1119     continue    
         rewind(19)
         do 1120 j1=1,nregly
         do 1120 j2=1,nreglat
         do 1120 j3=1,nreglon
         read(19,1819)regvep(j1,j3,j2)
c -- convert to m/s---------------------------------
         regvep(j1,j3,j2)=regvep(j1,j3,j2)*1000.
1120     continue    
         close(19)
         go to 1901
1818     format(f12.6,f12.6)
1819     format(t40,f9.6)
2999     kerr=1
1901     return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfreadsoil(kerr)

c PES 2011/07/21
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1

c -- reads soil type info from a modified .pgm ascii file-
         include 'soil1.h'
         character*50 filesb
c -- here's input file name
         filesb='soil3.pgm'
         fname=rpath(1:loc1)//'/'//filesb
         kerr = 0
         open(16,file=fname,status='old',err=5977)
         read(16,*)rlonmax,rlonmin,rlatmax,rlatmin
         read(16,*)nx,ny
         do 5309 i2=1,ny
         read(16,5310)(isb(i2,i3),i3=1,nx)
5309     continue
5310     format(15(i4))
c -- useful numbers
         rdely=(rlatmax-rlatmin)/ny
         rdelx=abs(rlonmax-rlonmin)/nx
         go to 5976
5977     kerr=1
5976     return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfmakereg(rla,rlo,rde,alp,bet,iregfl)
c -- define the regional tomo velocities -----------------------
         include 'regional.h'
         include 'regionald.h'
c        dimension vervep(4),verves(4)
         rd2rad=3.141593/180.
c -- set regional Vp/Vs here
         rvpvs=1.74
c -- too deep
         if(rde.gt.47000.*3.2808399)then
         alp=7900.
         bet=alp/rvpvs
         go to 6520
         endif
c -- find which box point is in--
         do 8139 l3=1,nreglat-1
         if(rla.le.reglat(l3).and.rla.gt.reglat(l3+1))then
         do 8249 l4=1,nreglon-1
         if(rlo.gt.reglon(l4).and.rlo.le.reglon(l4+1))then
         rrt=(rlo-reglon(l4))/(reglon(l4+1)-reglon(l4))
         rru=(rla-reglat(l3+1))/(reglat(l3)-reglat(l3+1))
c -- find layer
         do 6557 i=1,nregly-1
         if(rde.ge.reglay(i).and.rde.lt.reglay(i+1))then
         rscal=(rde-reglay(i))/(reglay(i+1)-reglay(i))
c -- interpolate top 4
         velop1=((1-rrt)*(1-rru)*regvep(i,l4,l3+1))+(rrt*(1-rru)*
     1    regvep(i,l4+1,l3+1))+(rrt*rru*regvep(i,l4+1,l3))+((1-rrt)*
     2    rru*regvep(i,l4,l3))
c -- interpolate bottom 4
         velop2=((1-rrt)*(1-rru)*regvep(i+1,l4,l3+1))+(rrt*(1-rru)*
     1    regvep(i+1,l4+1,l3+1))+(rrt*rru*regvep(i+1,l4+1,l3))+((1-rrt)*
     2    rru*regvep(i+1,l4,l3))
c -- interpolate layers -- assign velocity here
         alp=(rscal*velop2)+((1.-rscal)*velop1)
         bet=alp/rvpvs
         go to 6520
         endif
6557     continue
         endif
8249     continue
         endif
8139     continue
c -- missed model lat-long range, go to 1D
         do 6558 i2=1,nregly-1
         if(rde.ge.reglay(i2).and.rde.lt.reglay(i2+1))then
         alp=reg1dv(i2)
         bet=alp/rvpvs
         go to 6520
         endif
6558     continue
c -- done
6520     iregfl=1
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfgetsoil(rlatl0,rlonl0,isoilt,idgens)
c -- looks up soil type--------------------------------
         include 'soil1.h'
c -- soil type codes - follows Bay et al. 2005
c    1 Q01
c    2 Q02
c    3 Q03
c    4 Q04 aka Qafoc
c    5 Q05 aka Qg
c
c -- lat-long screen for detailed soil map area
         if(rlatl0.gt.rlatmax)then
          isoilt=1 
          idgens=2
          go to 5132
         endif
         if(rlatl0.lt.rlatmin)then
          isoilt=1
          idgens=2
          go to 5132 
         endif
         if(rlonl0.lt.rlonmax)then
          isoilt=1
          idgens=2
          go to 5132 
         endif
         if(rlonl0.gt.rlonmin)then 
          isoilt=1 
          idgens=2 
          go to 5132  
         endif 
c -- get soil type
         icolnm=abs(int((rlonmax-rlonl0)/rdelx))
         irownm=int((rlatmax-rlatl0)/rdely)
c -- white space - go Q01
c    this includes Great Salt and Utah lakes
         if(isb(irownm,icolnm).ge.250)then
          isoilt=1
          go to 5133
         endif
c -- black space - go generic
         if(isb(irownm,icolnm).le.2)then
          isoilt=1
          idgens=2
          go to 5132
         endif
c -- Q01   (red)
         if(isb(irownm,icolnm).ge.77.and.isb(irownm,icolnm).le.82)then
          isoilt=1
          go to 5133
         endif
c -- Q02   (green)
         if(isb(irownm,icolnm).ge.140.and.isb(irownm,icolnm).le.146)then
          isoilt=2
          go to 5133
         endif
c -- Q03   (blue)
         if(isb(irownm,icolnm).ge.30.and.isb(irownm,icolnm).le.35)then 
          isoilt=3 
          go to 5133 
         endif  
c -- Q04   (purple)
         if(isb(irownm,icolnm).ge.108.and.isb(irownm,icolnm).le.113)then 
          isoilt=4  
          go to 5133 
         endif
c -- Q05   (yellow)
         if(isb(irownm,icolnm).ge.219.and.isb(irownm,icolnm).le.224)then 
          isoilt=5   
          go to 5133  
         endif 
c -- latitude screen to tell which basin 
5133     continue
c -- Q01
         if(isoilt.eq.1)then
c -- Q01 in Utah basin
          if(rlatl0.lt.40.471710)then
          idgens=3
          go to 5132
          endif
c -- Q01 in Salt Lake basin
          if(rlatl0.ge.40.471710.and.rlatl0.lt.40.816667)then
          idgens=2
          go to 5132
          endif
c -- Q01 in Davis basin
          if(rlatl0.ge.40.816667.and.rlatl0.lt.41.067680)then
          idgens=1
          go to 5132
          endif
c -- Q01 in Weber basin
          if(rlatl0.ge.41.067680)then
           if(rlonl0.gt.-112.059970)then
           idgens=4
           else
           idgens=5
           endif
          go to 5132
          endif
c -- in case missed
          idgens=2
         endif
c -- Q02
         if(isoilt.eq.2)then
c -- Q02 in Utah basin
          if(rlatl0.lt.40.475050)then
          idgens=8
          go to 5132
          endif   
c -- Q02 in Salt Lake basin
          if(rlatl0.ge.40.475050.and.rlatl0.lt.40.816667)then
          idgens=7
          go to 5132
          endif
c -- Q02 in Davis basin
          if(rlatl0.ge.40.816667.and.rlatl0.lt.41.078018)then
          idgens=6    
          go to 5132
          endif 
c -- Q02 in Weber basin
          if(rlatl0.ge.41.078018)then
          idgens=9 
          go to 5132
          endif  
c -- in case missed
          idgens=7
         endif
c -- Q03
         if(isoilt.eq.3)then
c -- Q03 in Utah basin
          if(rlatl0.lt.40.471710)then
          idgens=11
          go to 5132 
          endif    
c -- Q03 in Salt Lake basin, and Davis, for which there is no data
          if(rlatl0.ge.40.471710.and.rlatl0.lt.41.078018)then
          idgens=10
          go to 5132 
          endif    
c -- Q03 in Weber basin
          if(rlatl0.ge.41.078018)then
          idgens=12
          go to 5132 
          endif   
c -- in case missed 
          idgens=10
         endif 
c -- Q04
c    have borehole data only from Cedar (Qafoc). No lat check.
          if(isoilt.eq.4)then
          idgens=13
          go to 5132
          endif
c -- Q05
         if(isoilt.eq.5)then
c -- Q05 in Utah basin 
          if(rlatl0.lt.40.475045)then
          idgens=15
          go to 5132
          endif
c -- Q05 in Salt Lake basin and all else north, for which there is no data
          if(rlatl0.ge.40.475045)then    
          idgens=14
          go to 5132
          endif
c -- in case missed
          idgens=14
         endif 
5132     return
        end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfreadgene(kerr)

c PES 2011/07/21
         character(128) rpath
         character(180) fname
         common/filestuff/rpath,fname,loc1

c -- read generic borehole profiles--------------------
         include 'genpro.h'
         character*16 fileig,ag1*50
c -- assign file name----------------------------------
         fileig='soil_generic4_lo'
         fname=rpath(1:loc1)//'/'//fileig
         kerr=0
c -- read file-----------------------------------------
         open(12,file=fname,status='old',err=2977)
         do 2300 k=1,numgen
          read(12,*)irt2
          numptge2(k)=irt2
c -- keep rmxdep in meters here, rdepgen in feet-------
          rmxdep(k)=(irt2-1)*1.
          do 2310 k1=1,irt2
           read(12,*)rvsgen(k,k1),rdepgen(k,k1)
           rdepgen(k,k1)=rdepgen(k,k1)*3.2808399
2310      continue
c -- skip label line, which follows data points--------
          read(12,*)ag1
2300      continue
         close(12)
         go to 2976
2977     kerr=1    
2976     return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfnearhole(rlat,rlon,isoilt)
c -- finds nearby geotech boreholes-------------------
         include 'borehole.h'
         include 'wtbh1.h'
         include 'wtbh1d.h'
         rtemdp=0.
         do 2227 i=1,nrad
         iradct(i)=0
          do 2228 k=1,numbh
          iradbh(i,k)=0
2228      continue
2227     continue
c -- loop over boreholes------------------------------
         do 667 k=1,numbh
c    keep borehole loc in case soil mis-id
          if(rlat.ne.rlatbh(k).and.rlon.ne.rlonbh(k))then
          if(isoilt.ne.isotype(k))go to 667
          endif
          rlod2=(rlon-rlonbh(k))*84.5259
          rlad2=(rlat-rlatbh(k))*111.0752
          rdel2=sqrt((rlod2**2.)+(rlad2**2.))
          if(rdel2.gt.radii(nrad))go to 667
c -- count close ones---------------------------------
c    keep only deepest within 1st radius
          do 668 l=2,nrad
           if(rdel2.ge.radii(l-1).and.rdel2.lt.radii(l))then
             if(l.eq.2)then
              if(rbhdmx(k).gt.rtemdp)then
              rtemdp=rbhdmx(k)
              iradct(2)=1
              iradbh(2,iradct(2))=k
             else
              go to 668
              endif
             endif
            iradct(l)=iradct(l)+1
            iradbh(l,iradct(l))=k
           endif
668       continue
667      continue
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine wfaddtopp(rdep,rvelo,idgen,ifs,rveln,r1de)
c -- returns S velocity from 'geotech' constraints-----
c    rvelo = current velocity from main code
c    rveln = new (from here) velocity passed back
c    iradct array = number of nearby boreholes
c    iradctp = number of nearby boreholes with data
         include 'borehole.h'
         include 'genpro.h'
         include 'wtbh1.h'
         include 'wtbh3.h'
         rtvelges=0.
         do 97013 n=1,nrad
         iradctp(n)=0
         radvp(n)=0.
97013     continue
          do 97011 l=2,nrad
           do 97012 i=1,iradct(l)
           k=iradbh(l,i)
            do 9669 n=1,numptbh(k)
c -- check for data at this depth----------------------
            if(rdep.le.rdepbh(k,n))then
             rva=rvs(k,n)
            if(rva.ne.0.)then
c -- this gives borehole within 50 m-------------------
             if(l.eq.2)then
              rveln=rva
              go to 9671
             else   
              iradctp(l)=iradctp(l)+1
              radvp(l)=radvp(l)+rva
              go to 9669
             endif
            endif
            endif
9669         continue
97012       continue
97011      continue
c -- check ifs flag-----------------------------------
c    info for possible taper
c    within 50 m of borehole - ignore generic
         if(iradct(2).ne.0)then
          kk=iradbh(2,1)
          rxxdep=rbhdmx(kk)
          rv1=rvs(kk,numptbh(kk))
          go to 9133
         endif
c    below generic
         if(ifs.eq.0)then
          rxxdep=(rmxdep(idgen))*3.2808399
          rv1=rvsgen(idgen,numptge2(idgen))
          go to 9133
         endif
c -- weight for velocity------------------------------
         do 9670 j=3,nrad
         if(iradctp(j).ne.0)then
          rtvelp(j)=radvp(j)/iradctp(j)
          rtewtp(j)=radwt(j)
          else
          rtewtp(j)=0.
         endif
9670      continue
c -- get generic profile velocity---------------------
         do 9870 n=2,numptge2(idgen)
c -- catch a special case
          if(rdep.eq.(rmxdep(idgen)*3.2808399))then
          rtvelges=rvsgen(idgen,numptge2(idgen))
          go to 9871
          endif
        if(rdep.ge.rdepgen(idgen,n-1).and.rdep.lt.rdepgen(idgen,n))then
          rtvelges=rvsgen(idgen,n-1)
          go to 9871
          endif
9870      continue
9871      continue
c -- get the velocities-------------------------------
         rb=0.
         rscfac=1./((nrad-3)+1)
c -- better always have generic velo------------------
         do 91110 n=3,nrad
         rb=rb+(((rtewtp(n)*rtvelp(n))+((1.-rtewtp(n))*rtvelges))
     1   *rscfac)
91110     continue
         rveln=rb
         go to 9671
c -- taper between generics or borehole and R1 depth--
9133      continue
         rtfac=((rdep-rxxdep)/(r1de-rxxdep))
         if(rtfac.gt.1.)rtfac=1.
         rtfac2=cos(rtfac*(3.141592654/2.))
         rv2=rvelo
         rvte3=(rtfac2*rv1)+((1.-rtfac2)*rv2)
         rveln=rvte3
c -- done---------------------------------------------
9671      continue
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine taperp(rdep,alpold,rhoold,alphx,rhx,alphy,rhy,r2de,
     1   idgen)
c -- taper S velocity based Vp and density into the P velocity values
         include 'genpro.h'
         rx2dep=(rmxdep(idgen))*3.2808399
         r2fac=((rdep-rx2dep)/(r2de-rx2dep))
         if(r2fac.gt.1.)r2fac=1.
         r2fac2=cos(r2fac*(3.141592654/2.))
         rv8=alphx
         rv9=alpold
         rd1=rhx
         rd2=rhoold
         rvte5=(r2fac2*rv8)+((1.-r2fac2)*rv9)
         rvde5=(r2fac2*rd1)+((1.-r2fac2)*rd2)
         alphy=rvte5
         rhy=rvde5
c -- done---------------------------------------------
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine nearhol2(rlat,rlon,l2flag)
c -- finds nearby geotech boreholes-------------------
         include 'borehole.h'
         include 'wtbh1.h'
         rtemdp=0.
         l2flag=0
         do 22279 i=1,nrad
         iradct(i)=0
          do 22289 k=1,numbh
          iradbh(i,k)=0
22289      continue
22279     continue
c -- loop over boreholes------------------------------
         do 6679 k=1,numbh
          rlod2=(rlon-rlonbh(k))*84.5259
          rlad2=(rlat-rlatbh(k))*111.0752
          rdel2=sqrt((rlod2**2.)+(rlad2**2.))
          if(rdel2.gt.radii(nrad))go to 6679
c -- count close ones---------------------------------
c    keep only deepest within 1st radius
          do 6689 l=2,nrad
           if(rdel2.ge.radii(l-1).and.rdel2.lt.radii(l))then
             if(l.eq.2)then
              l2flag=1
              if(rbhdmx(k).gt.rtemdp)then
              rtemdp=rbhdmx(k)
              iradct(2)=1
              iradbh(2,iradct(2))=k
             else
              go to 6689
              endif
             endif
            iradct(l)=iradct(l)+1
            iradbh(l,iradct(l))=k
           endif
6689       continue
6679      continue
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine addtop2(rdep,rvelo,rveln)
c -- returns S velocity from borehole below R1---------
c    only for boreholes in 50 m (nrad=2)
c    does not weigh in generic profiles
         include 'borehole.h'
         include 'wtbh1.h'
c -- have only 1 borehole within 50 m, the deepest-----
            k=iradbh(2,1)
            do 96691 n=1,numptbh(k)
c -- check for data at this depth----------------------
            if(rdep.le.rdepbh(k,n))then
             rva=rvs(k,n)
             rveln=rva
             go to 96711
            endif
96691       continue
            rveln=rvelo
c -- done---------------------------------------------
96711     continue
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine addtop3(rdep,rvelo,idgen,ifs,rveln)
c -- returns S velocity from 'geotech' constraints-----
c    rvelo = current velocity from main code
c    rveln = new (from here) velocity passed back
c    iradct array = number of nearby boreholes
c    iradctp = number of nearby boreholes with data
         include 'borehole.h'
         include 'genpro.h'
         include 'wtbh1.h'
         include 'wtbh3.h'
         rtvelges=0.
         do 17013 n=1,nrad
         iradctp(n)=0
         radvp(n)=0.
17013     continue
          do 17011 l=2,nrad
           do 17012 i=1,iradct(l)
           k=iradbh(l,i)
            do 1669 n=1,numptbh(k)
c -- check for data at this depth----------------------
            if(rdep.le.rdepbh(k,n))then
             rva=rvs(k,n)
            if(rva.ne.0.)then
c -- this gives borehole within 50 m-------------------
             if(l.eq.2)then
             rveln=rva
             go to 1671
             else   
             iradctp(l)=iradctp(l)+1
             radvp(l)=radvp(l)+rva
             go to 1669
             endif
            endif
            endif
1669         continue
17012       continue
17011      continue
c -- check ifs flag-----------------------------------
         if(ifs.eq.0)go to 1133
c -- weight for velocity------------------------------
         do 1670 j=3,nrad
         if(iradctp(j).ne.0)then
          rtvelp(j)=radvp(j)/iradctp(j)
          rtewtp(j)=radwt(j)
          else
          rtewtp(j)=0.
         endif
1670      continue
c -- get generic profile velocity---------------------
         do 1870 n=2,numptge2(idgen)
c -- catch a special case
          if(rdep.eq.(rmxdep(idgen)*3.2808399))then
          rtvelges=rvsgen(idgen,numptge2(idgen))
          go to 1871
          endif
        if(rdep.ge.rdepgen(idgen,n-1).and.rdep.lt.rdepgen(idgen,n))then
          rtvelges=rvsgen(idgen,n-1)
          go to 1871
          endif
1870      continue
1871      continue
c -- get the velocities-------------------------------
         rb=0.
         rscfac=1./((nrad-3)+1)
c -- better always have generic velo------------------
         do 11110 n=3,nrad
         rb=rb+(((rtewtp(n)*rtvelp(n))+((1.-rtewtp(n))*rtvelges))
     1   *rscfac)
11110     continue
         rveln=rb
         go to 1671
c -- between generics and geotech depth, so see  -----
c    if rule model or bottom of generic is faster
1133      continue
         rv1=rvsgen(idgen,numptge2(idgen))
         rv2=rvelo
         rveln=amax1(rv1,rv2)
c -- done---------------------------------------------
1671      continue
         return
         end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         subroutine getkay(rlat10,rlon10,iup,rkall)
c -- figure out which 'k' -----------------------------
c
c -- latitude screen to tell which basin 
c 
c surface #   surface
c   1         R3 aka basement
c   2         R2
c   3         R1
c
          include 'rkinfo.h'
c -- defaults
         rkall(1)=170.
         rkall(2)=170.
         rkall(3)=140.
c  some Utah basin R1
         if(rlon10.lt.-111.82979664.and.rlat10.lt.40.4621877)then
         rkall(3)=137.
         endif
         if(rlon10.ge.-111.82979664.and.rlat10.lt.40.4942606)then
         rkall(3)=137.
         endif
c -- in Utah basin
          if(rlat10.lt.40.471710)then
           if(iup.eq.2)then
           rkall(1)=160
           rkall(2)=200
c          rkall(3)=170.
           go to 45132
           endif
          endif
c -- in Salt Lake basin
          if(rlat10.ge.40.471710.and.rlat10.lt.40.818200)then
           rkall(3)=170.
           if(iup.eq.2)then
           rkall(1)=183
           rkall(2)=207
           go to 45132
           endif
          endif
c -- in Davis basin
          if(rlat10.ge.40.818200.and.rlat10.lt.41.067680)then
           rkall(3)=170.
           if(iup.eq.2)then
           rkall(1)=192
           rkall(2)=207
           go to 45132
           endif
          endif
c -- in Weber basin
c    longitude bound here to islands in GSL
          if(rlat10.ge.41.067680)then
c          if(rlon10.gt.-112.059970)then
           if(rlon10.gt.-112.387046)then
            rkall(3)=170.
            if(iup.eq.2)then
            rkall(1)=160
            rkall(2)=150
c           rkall(3)=170.
            go to 45132
            endif
           endif
          endif
          go to 45132
c -- someday add other basin screens here
c
45132   continue
        return
        end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
