

! Program for calculating Q0

	program QCalculation

	implicit none
	integer :: i, j, k, file_len, cnt1
	real :: time_b, time_e, freq, time_f, wdw, cnt, tim_rms, amp_rms, log_amp
	real :: Sx, Sy, Sxx, Syy, Sxy, det, m1, m2, meanerror, residual, RR, ss, Q, Qe, Var_a, Var_b, ssxx, em1
        real, dimension(:), allocatable :: tim, amp, t_rms, l_rms
	character (len=100) :: fname
	
	!reading file
        read(*,*)fname
	open(20,file=fname,status='old')
        !reading file length
        read(*,*) file_len
	!reading frequency
        read(*,*) freq
	!open temp file
	open(30, file="temp", status='new')
	!variables

	allocate (tim(file_len))
	allocate (amp(file_len))
	
	
	do 11 i = 1, file_len
		read(20,*) tim(i), amp(i)
		!print*, tim(j), amp(j)
11	end do	
	

	time_b = tim(1)
	wdw = 5/freq
	time_e = 0.0
	time_f = tim(file_len)
	cnt1 = 1
	do 12 while (time_e <= time_f)
		time_e = time_b + wdw
		cnt = 0.0
		amp_rms = 0.0

		do 13 j = 1, file_len
			if (tim(j) >= time_b .and. tim(j) <= time_e) then
				amp_rms = amp_rms + amp(j)*amp(j)
				cnt = cnt + 1.0
			end if
		
13		end do	
		tim_rms = (time_b + time_e)/2.0
		time_b = time_b + wdw/2.0
		log_amp = log((amp_rms/cnt)**0.5)+log(tim_rms)
		cnt1 = cnt1 + 1
		write(30,*) tim_rms, log_amp
		!write(30,*) tim_rms, (amp_rms/cnt)**0.5

12	end do
	close(30)
	open(40, file="temp", status='old')
	cnt1 = cnt1 -1	

	allocate (t_rms(cnt1))
	allocate (l_rms(cnt1))

	do 14 i = 1, cnt1
		read(40,*) t_rms(i), l_rms(i)
		!print*, t_rms(i), l_rms(i), cnt1, i		
14	end do
	close(40)
	open(50, file="temp", status='replace')
	open(60, file="temp2", status='new')
!---------------------------------------------------------------------------------------
!Linear Regression
	
81	Sx = 0.0
	Sy = 0.0
	Sxx = 0.0
	Syy = 0.0
	Sxy = 0.0
	
	do 75 j = 1, cnt1 
		Sx = Sx + t_rms(j)
		Sy = Sy + l_rms(j)
		Sxx = Sxx + t_rms(j)*t_rms(j)
		Syy = Syy + l_rms(j)*l_rms(j)
		Sxy = Sxy + t_rms(j)*l_rms(j)
	
75	end do

	det = Sxx * cnt1 - Sx * Sx
	m1 = (Sxy * cnt1 - Sy * Sx)/det
	m2 = (Sxx * sy - Sx * Sxy)/det
	!print*, det, "-----", m1, "-------", m2
	
	meanerror = 0.0
	residual = 0.0
	ssxx = 0.0
	do 85 j = 1, cnt1
		ssxx = ssxx + (t_rms(j) - Sx/cnt1)**2
		meanerror = meanerror + (l_rms(j) - Sy/cnt1)**2
		residual = residual + (l_rms(j) - (m1 * t_rms(j) + m2))**2 !sum((yi-y^)^2)
85 	end do
	RR = 1 - residual/meanerror
	ss = residual / (cnt1-2) !square of standard error of estimate (estimator of sigma(error))
	Var_a = ss * cnt1 / det
	Var_b = ss * Sxx / det
	
	do 65 j = 1, cnt1
		write(50,*) t_rms(j), l_rms(j), m1*t_rms(j) + m2
	
65	end do
	em1 = sqrt(ss/ssxx)
	Q = (-1.0*3.14159*freq)/m1
	Qe = abs(3.14159*freq/m1**2.0)*em1 !error in Q

	write(60,*), Q, Qe, freq, m1, m2, sqrt(Var_a), sqrt(Var_b), RR, sqrt(ss) ! sqrt(ss) is the standard error of estimates
	close(60)
!------------------------------------------------------------------------------------------
	close(50)
	close(20)
8888    stop
	end program QCalculation



