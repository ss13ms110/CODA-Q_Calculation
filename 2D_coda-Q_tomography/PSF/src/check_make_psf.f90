!program to calculate check for forward calculation

program	CheckMake
implicit none

	integer :: i, j, k, xlen, ylen, Ng, ix, iy, binvalue
	real :: grdsz, longA, longB, latA, latB, dummy, sqsize
	real, dimension(:), allocatable :: long, lat, Q
	real, dimension(:,:), allocatable :: Q1, Q2	
	
	longA = 82.0
	longB = 100.0
	latA = 19.0
	latB = 35.0
	grdsz = 0.2
	ylen = (latB - latA)/grdsz - 1
	xlen = (longB - longA)/grdsz - 1
	Ng = (xlen)*(ylen)	
	sqsize = 10.0
		
	allocate(lat(Ng))
	allocate(long(Ng))
	allocate(Q(Ng))	
	allocate(Q1(ylen,xlen))
	allocate(Q2(ylen,xlen))
	
	open(10,file="inp.txt",status='replace')
	open(20,file="01_weightage.txt",status='old')
	read(20,*) dummy
	read(20,*) long
	read(20,*) lat
	close(20)

	k = 1
	do j = 1, ylen
		do i = 1, xlen
		iy = int(lat(k)/sqsize) + 1
    		ix = int((long(k) - 0)/sqsize) + 1
    		binvalue = mod(ix+iy,2)
    			!if(binvalue == 0) then
			!if(long(k)>86.0 .and. long(k)<94.0 .and. lat(k)>23.0 .and. lat(k)<29.0) then
			if(long(k)>87.0 .and. long(k)<89.0 .and. lat(k)>26.0 .and. lat(k)<29.0) then
			Q(k) = 1
			else if (long(k)>91.5 .and. long(k)<93.5 .and. lat(k)>24.0 .and. lat(k)<27.0) then
			Q(k) = 1
			else
			Q(k) = 0
			end if
		k = k + 1
		end do
	end do
	k = 0
	do j = 1, ylen
		do i = 1, xlen
			Q1(j,i) = Q(i+k)
		end do
		k = k + xlen
	end do
		
	!call smoothen(Q1, Q2, xlen, ylen)
	call Gaussian10(Q1, Q2, xlen, ylen)
	k = 0
	do j = 1, ylen
		do i = 1, xlen
			Q(i+k) = Q1(j,i)
		end do
		k = k + xlen
	end do
	
	k = 1
	do j = 1, ylen
		do i = 1, xlen	
		if(Q(k) == 0.0) then
		write(10,*), long(k), lat(k), 0
		else
		write(10,*), long(k), lat(k), Q(k)
		end if
		k = k + 1
		end do
	end do
	
	close(10)
end program CheckMake

!------------------------------------------------------------------
!SUBROUTINE
!------------------------------------------------------------------

	subroutine Saussian9( Qm1, Qm2, xlen, ylen )
		integer :: xlen, ylen, x, y
		real, dimension(ylen,xlen) :: Qm1, Qm2

		do x = 2, xlen-2
			do y = 2, ylen-2
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

				else if (x == xlen-1 .and. y == 0) then 
					Qm2(y,x) = (1.0/18.0)*(Qm1(y+1,x-1) + 4.0*(Qm1(y+1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))

				else if (x == 0 .and. y==ylen-1) then
					Qm2(y,x) = (1.0/18.0)*(Qm1(y-1,x+1) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)) + 9.0*Qm1(y,x))

				else if (x == xlen-1 .and. y == ylen-1) then
					Qm2(y,x) = (1.0/18.0)*(Qm1(y-1,x-1) + 4.0*(Qm1(y-1,x)+Qm1(y,x-1)) + 9.0*Qm1(y,x))

				else if (x == 0 .and. y /= 0 .and. y/= ylen-1) then
					Qm2(y,x) = (1.0/23.0)*((Qm1(y-1,x+1) +Qm1(y+1,x+1)) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)) + 9.0*Qm1(y,x))

				else if (x == xlen-1 .and. y /= 0 .and. y/= ylen-1) then

					Qm2(y,x) = (1.0/23.0)*((Qm1(y-1,x-1) +Qm1(y+1,x-1)) + 4.0*(Qm1(y,x-1)+Qm1(y-1,x)+Qm1(y+1,x)) + 9.0*Qm1(y,x))
				else if (y == 0 .and. x /= 0 .and. x /= xlen-1) then

					Qm2(y,x) = (1.0/23.0)*((Qm1(y+1,x-1) +Qm1(y+1,x+1)) + 4.0*(Qm1(y-1,x)+Qm1(y,x+1)+Qm1(y+1,x)) + 9.0*Qm1(y,x))
				else if (y == ylen-1 .and. x /= 0 .and. x/= xlen-1) then

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
