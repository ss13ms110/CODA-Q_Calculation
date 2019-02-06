!program to run Back Projection written on 14-01-2017

program BackProjection

implicit none

	integer :: j, xlen, ylen, Ng, Nd, k, it, iterations, x, y, ss, jj, kk, i
	real :: grdsz, longA, longB, latA, latB, dummy, lenQ, inQ, sm, dp, t1sum, error, tmp
	real, dimension(:), allocatable :: long, lat, Q0, sn, Qm0, resid0, resid1, snn, Q_con, Qmm, e, Q0q
	real, dimension(:,:), allocatable :: Gmat, Qm1, Qm2
	character (len=50) :: filename, format_string, Ndd, freq, filename1, format_string1, dumm

	call getarg(1,freq)
	call getarg(2,Ndd) !no. of traces
	read( Ndd, '(I3)') Nd
	format_string = "(A2,A11)"
	write (filename,format_string) freq,"_output.txt"

	!give value to variables
	longA = 82.0
	longB = 100.0
	latA = 19.0
	latB = 35.0
	grdsz = 0.2
	!Nd = 585	!no. of traces
	iterations = 10	!no. of iterations
	!dp = 1/float(Nd)	!damping parameter
	dp = 0.002274		!damping parameter
	ylen = (latB - latA)/grdsz - 1
	xlen = (longB - longA)/grdsz - 1
	Ng = (xlen)*(ylen)
	lenQ = Nd

	!allocation 
	allocate(lat(Ng))
	allocate(long(Ng))
	allocate(Q0(Nd))
	allocate(Q0q(Nd))
	allocate(Q_con(Nd))
	allocate(Gmat(Ng+1,Nd))
	allocate(sn(Nd))
	allocate(Qm0(Ng))
	allocate(Qmm(Ng))
	allocate(resid0(Nd))
	allocate(resid1(Nd))
	allocate(snn(Nd))
	allocate(Qm1(ylen,xlen))
	allocate(Qm2(ylen,xlen))
	allocate(e(Ng))
	
	!running loop and setting Qm2 values
	do y = 1, ylen
		do x = 1, xlen
			Qm2(y,x) = 0.0
		end do
	end do

	format_string1 = "(A2,A14)"
	write (filename1,format_string1) freq,"_weightage.txt"
	open(20,file=trim(filename1),status='old')
	!open(20,file="01_weightage.txt",status='old')
	read(20,*) dummy
	read(20,*) long
	read(20,*) lat
	read(20,*) Q0
	close(20)
	
	!open(50,file="cata_all.txt",status="old")
	!do i = 1, Nd
	!read(50,*) dumm, Q0(i)
	!end do
	!close(50)

	!opening and reading Gmatrix file
	open(30,file="Gmatrix.txt",status='old')
	read(30,*) Gmat
	close(30)
	
	!getting the sum(sn) of overlapping area and the sum(snn) of squares of weightage
	do j = 1, Nd
		tmp = 0.0
		do k = 1, Ng
			tmp = tmp + (Gmat(k,j))**2.0
		end do
		snn(j) = tmp
		sn(j) = Gmat(Ng+1,j)
	end do

	!giving uniform Q value to all grid points	
	inQ = (sum(Q0)/lenQ)*0.95
	do j = 1, Ng
		Qm0(j) = inQ
	end do
	print*, inQ
	!open(333,file="00_re",status="replace")
	!i = 1
	!do y = 1, ylen
	!do x = 1, xlen
		!write(333,*), long(i), lat(i), Qm0(i)
		!i = i + 1 
	!end do
	!end do


	!getting initial residual error
	do j = 1, Nd
		sm = 0.0
		do k = 1, Ng
			sm = sm + Gmat(k,j)/Qm0(k)
		end do
		resid0(j) = sn(j)/Q0(j) - sm
	end do

	!open(1,file="01_re",status="replace")
	!open(2,file="02_re",status="replace")
	!open(3,file="03_re",status="replace")
!--------------------------------------------------------------
!Iterations starts from here
!--------------------------------------------------------------
	do it = 1, iterations
		do j = 1, Nd
			sm = 0.0
			do k = 1, Ng
				sm = sm + Gmat(k,j)/Qm0(k)
			end do
			resid1(j) = sn(j)/Q0(j) - sm
!-----------------------------------------------------------
! little modifications for plot
			Q_con(j) = sn(j)/sm
!-----------------------------------------------------------
		end do
		!print*, it, Q0(10), Q_con(10)
		do k = 1, Ng
			t1sum = 0.0
			do j = 1, Nd
				t1sum = t1sum + (resid1(j)*Gmat(k,j))/snn(j)
			end do
			t1sum = t1sum*dp
			
			Qmm(k) = 1.0/((1.0/Qm0(k)) + t1sum)
		end do
		!print*, pp,mm
		ss = 0.0
		do y = 1, ylen
			do x = 1, xlen
				Qm1(y,x) = Qmm(x+ss)
			end do
			ss = ss + xlen
		end do

		do y = 1, ylen
			do x = 1, xlen
				Qm2(y,x) = Qm1(y,x)
			end do
		end do

		
		!calling subroutine
		call Saussian9(Qm1, Qm2, xlen, ylen)
		!call Gaussian9(Qm1, Qm2, xlen, ylen)
		
		ss = 0.0
		do y = 1, ylen
			do x = 1, xlen
				 Qm0(x+ss) = Qm2(y,x)
			end do
			ss = ss + xlen
		end do

		!break the loop if condition satisfied
		error = sum(resid1**2.0)/sum(resid0**2.0) - 1
		print*, abs(error), it
		
		resid0 = resid1
		if (abs(error) < 10**(-6.0) .and. it>200) then
			go to 50
		end if
		
		!i = 1
		!do y = 1, ylen
		!do x = 1, xlen
			!write(it,*), long(i), lat(i), Qm2(y,x), e(i)
			!i = i + 1 
		!end do
		!end do
	close(40)
	end do


	
50	open(40, file=trim(filename), status='replace')
!50	open(40, file="01_output.txt", status='replace')

	i = 1
	do y = 1, ylen
		do x = 1, xlen
			write(40,*), long(i), lat(i), Qm2(y,x)
			i = i + 1 
		end do
	end do
	close(40)
	

end program BackProjection

!------------------------------------------------------------------
!SUBROUTINE
!------------------------------------------------------------------

	subroutine Saussian9( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2

		do y = 2, ylen-2
			do x = 2, xlen-2
				Qm2(y,x) = 1.0/((1.0/209.0)*(16.0*(1/Qm1(y-1,x-1)+1/Qm1(y-1,x+1)+1/Qm1(y+1,x+1)+&
				1/Qm1(y+1,x-1))+26.0*(1/Qm1(y-1,x)+1/Qm1(y,x-1)+1/Qm1(y+1,x)+&
				1/Qm1(y,x+1))+41.0*(1/Qm1(y,x))))
			end do
		end do
		!print*, "----------"
	return
	end subroutine Saussian9

!	subroutine Saussian9( Qm1, Qm2, xlen, ylen )
!		integer :: xlen, ylen, x, y
!		real, dimension(ylen,xlen) :: Qm1, Qm2

!		do y = 2, ylen-2
!			do x = 2, xlen-2
!				Qm2(y,x) = 1.0/((1.0/209.0)*(16.0*(Qm1(y-1,x-1)**(-1.0)+Qm1(y-1,x+1)**(-1.0)+Qm1(y+1,x+1)**(-1.0)+&
!				Qm1(y+1,x-1)**(-1.0))+26.0*(Qm1(y-1,x)**(-1.0)+Qm1(y,x-1)**(-1.0)+Qm1(y+1,x)**(-1.0)+&
!				Qm1(y,x+1)**(-1.0))+41.0*(Qm1(y,x)**(-1.0))))
!			end do
!		end do
		!print*, "----------"
!	return
!	end subroutine Saussian9

	subroutine Gaussian9( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2

		do y = 2, ylen-2
			do x = 2, xlen-2
				Qm2(y,x) = (1.0/29.0)*((Qm1(y-1,x+1) +Qm1(y+1,x+1) +Qm1(y+1,x-1) +Qm1(y-1,x-1)) + &
					4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))
			end do
		end do
		!print*, "----------"
	return
	end subroutine Gaussian9








	

