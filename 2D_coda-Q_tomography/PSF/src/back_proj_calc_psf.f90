!program to run Back Projection written on 14-01-2017

program BackProjection

implicit none

	integer :: j, xlen, ylen, Ng, Nd, k, it, iterations, x, y, ss, jj, kk, i
	real :: grdsz, longA, longB, latA, latB, dummy, dum1, dum2, lenQ, inQ, sm, dp, t1sum, error, tmp
	real, dimension(:), allocatable :: long, lat, Q0, sn, Qm0, resid0, resid1, snn
	real, dimension(:,:), allocatable :: Gmat, Qm1, Qm2
	!character (len=2) :: freq
	character (len=50) :: filename, format_string, Ndd, freq

	!call getarg(1,freq)
	call getarg(1,Ndd) !no. of traces
	read( Ndd, '(I3)') Nd
	!print*, Nd, "????"
	!format_string = "(A2,A11)"
	!write (filename,format_string) freq,"_output.txt"
	!print*, filename
	!give value to variables
	longA = 82.0
	longB = 100.0
	latA = 19.0
	latB = 35.0
	grdsz = 0.2
	!Nd = 634	!no. of traces
	iterations =  10	!no. of iterations
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
	allocate(Gmat(Ng+1,Nd))
	allocate(sn(Nd))
	allocate(Qm0(Ng))
	allocate(resid0(Nd))
	allocate(resid1(Nd))
	allocate(snn(Nd))
	allocate(Qm1(ylen,xlen))
	allocate(Qm2(ylen,xlen))
	
	!open(60, file="ss.txt", status='replace')
	!do while (dp <= 0.004000)


	
	!running loop and setting Qm2 values
	do y = 1, ylen
		do x = 1, xlen
			Qm2(y,x) = 0.0
		end do
	end do

	open(20,file="01_weightage.txt",status='old')
	read(20,*) dummy
	read(20,*) long
	read(20,*) lat
	close(20)
	
	open(25,file="Q_inp.txt",status='old')
	do y = 1, Nd
		read(25,*) Q0(y)
	end do

	close(25)
	!opening and reading Gmatrix file
	open(30,file="Gmatrix.txt",status='old')
	read(30,*) Gmat
	close(30)
	
	!getting the sum(sn) of overlapping area and the sum(snn) of squares of weightage
	do j = 1, Nd
		tmp = 0.0
		do k = 1, Ng
			tmp = tmp + Gmat(k,j)*Gmat(k,j)
		end do
		snn(j) = tmp
		sn(j) = Gmat(Ng+1,j)
	end do

	!open(11,file="inp.txt",status='old')
	!do j = 1, Ng
	!	read(11,*) dum1, dum2, Qm0(j)
	!end do
	!close(11)
	
	!giving uniform Q value to all grid points	
	!inQ = sum(Q0)/lenQ
	do j = 1, Ng
		Qm0(j) = 0.0
	end do

	!getting initial residual error
	do j = 1, Nd
		sm = 0.0
		do k = 1, Ng
			sm = sm + Gmat(k,j)*Qm0(k)
		end do
		resid0(j) = sn(j)*Q0(j) - sm
	end do

	
	!error=0.0
!--------------------------------------------------------------
!Iterations starts from here
!--------------------------------------------------------------
	do it = 1, iterations
		do j = 1, Nd
			sm = 0.0
			do k = 1, Ng
				sm = sm + Gmat(k,j)*Qm0(k)
			end do
			resid1(j) = sn(j)*Q0(j) - sm
		end do
		
		do k = 1, Ng
			t1sum = 0.0
			do j = 1, Nd
				t1sum = t1sum + (resid1(j)*Gmat(k,j))/snn(j)
			end do
			t1sum = t1sum*dp
			Qm0(k) = Qm0(k) + t1sum
		end do
		!print*, Qm0(1046)
		ss = 0.0
		do y = 1, ylen
			do x = 1, xlen
				Qm1(y,x) = Qm0(x+ss)
			end do
			ss = ss + xlen
		end do

		
		!calling subroutine
		!call smoothen(Qm1, Qm2, xlen, ylen)
		call Gaussian9(Qm1, Qm2, xlen, ylen)
		ss = 0.0
		do y = 1, ylen
			do x = 1, xlen
				 Qm0(x+ss) = Qm1(y,x)
			end do
			ss = ss + xlen
		end do

		!break the loop if condition satisfied
		error = sum(resid1**2.0)/sum(resid0**2.0) - 1
		print*, error, it
		!write(60,*), abs(error), dp, it
		!print*, abs(error), dp, it	
		resid0 = resid1
		if (abs(error) < 10**(-6.0) .and. it>200) then
			go to 50
		end if
		
	end do

	!error = error/50.0
	
	!write(60,*), error, dp
!50	open(40, file=trim(filename), status='replace')
50	open(40, file="output.txt", status='replace')

	i = 1
	do y = 1, ylen
		do x = 1, xlen
			write(40,*), long(i), lat(i), Qm2(y,x)
			i = i + 1 
		end do
	end do
	close(40)
	!dp = dp + 0.000250
	!write(60,*)
	!end do
	!close(60)

end program BackProjection

!------------------------------------------------------------------
!SUBROUTINE
!------------------------------------------------------------------

	subroutine Saussian9( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2

		do y = 2, ylen-2
			do x = 2, xlen-2
				Qm2(y,x) = 1.0/((1.0/209.0)*(16.0*(Qm1(y-1,x-1)**(-1.0)+Qm1(y-1,x+1)**(-1.0)+Qm1(y+1,x+1)**(-1.0)+&
				Qm1(y+1,x-1)**(-1.0))+26.0*(Qm1(y-1,x)**(-1.0)+Qm1(y,x-1)**(-1.0)+Qm1(y+1,x)**(-1.0)+&
				Qm1(y,x+1)**(-1.0))+41.0*(Qm1(y,x)**(-1.0))))
			end do
		end do
		!print*, "----------"
	return
	end subroutine Saussian9

	subroutine smoothen( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2
		
		do y = 1, ylen
			do x = 1, xlen
				if (x == 0 .and. y == 0) then
					Qm2(y,x) = (1.0/18.0)*(Qm1(y+1,x+1) + 4.0*(Qm1(y+1,x)+Qm1(y,x+1)) + 9.0*Qm1(y,x))

				else if (x == xlen .and. y == 0) then 
					Qm2(y,x) = (1.0/18.0)*(Qm1(y+1,x-1) + 4.0*(Qm1(y+1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))

				else if (x == 0 .and. y==ylen) then
					Qm2(y,x) = (1.0/18.0)*(Qm1(y-1,x+1) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)) + 9.0*Qm1(y,x))

				else if (x == xlen-1 .and. y == ylen) then
					Qm2(y,x) = (1.0/18.0)*(Qm1(y-1,x-1) + 4.0*(Qm1(y-1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))

				else if (x == 0 .and. y /= 0 .and. y/= ylen) then
					Qm2(y,x) = (1.0/23.0)*((Qm1(y-1,x+1) +Qm1(y+1,x+1)) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)) + 9.0*Qm1(y,x))

				else if (x == xlen .and. y /= 0 .and. y/= ylen) then

					Qm2(y,x) = (1.0/23.0)*((Qm1(y-1,x-1) +Qm1(y+1,x-1)) + 4.0*(Qm1(y,x-1)+Qm1(y-1,x)+Qm1(y+1,x)) + 9.0*Qm1(y,x))
				else if (y == 0 .and. x /= 0 .and. x /= xlen) then

					Qm2(y,x) = (1.0/23.0)*((Qm1(y+1,x-1) +Qm1(y+1,x+1)) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)) + 9.0*Qm1(y,x))
				else if (y == ylen .and. x /= 0 .and. x/= xlen) then

					Qm2(y,x) = (1.0/23.0)*((Qm1(y-1,x+1) +Qm1(y-1,x-1)) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y,x-1)) + 9.0*Qm1(y,x))
				else
					Qm2(y,x) = (1.0/29.0)*((Qm1(y-1,x+1) +Qm1(y+1,x+1) +Qm1(y+1,x-1) +Qm1(y-1,x-1)) + &
					4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))
				end if
			end do
		end do
		!print*, "----------"
	return
	end subroutine smoothen

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

	subroutine Gaussian10( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2

		do y = 2, ylen-2
			do x = 2, xlen-2
				Qm2(y,x) = (1.0/9.0)*((Qm1(y-1,x+1) +Qm1(y+1,x+1) +Qm1(y+1,x-1) +Qm1(y-1,x-1)) + &
					(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)+Qm1(y,x-1)) + Qm1(y,x))
			end do
		end do
		!print*, "----------"
	return
	end subroutine Gaussian10



	

