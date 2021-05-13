c contains data statements for surfaces
c surface #   surface
c   1         R3 aka basement
c   2         R2
c   3         R1
c rkall(x) now gets set in subroutine getkay
c nedge is not used
        dimension rage(numsur),rupl(numsur),rfacs(numsur)
        data(nlosur(i),i=1,numsur)/241,241,241/
        data(nlasur(i),i=1,numsur)/550,550,550/
        data(rage(i),i=1,numsur)/20000000.,10000000.,5000000./
        data(rupl(i),i=1,numsur)/0.,0.,0./
c       data(nedge(i),i=1,numsur)/5,5,5/
c       data(rkall(i),i=1,numsur)/180.,180.,170./
        data(rfacs(i),i=1,numsur)/.166666667,.166666667,.166666667/
c nominal surface age
        data ragesur/3000000./
