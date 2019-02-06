

! Program for calculating Q0

	program QCalculation

	implicit none
	integer :: j, file_len
	real :: M11, M12, M22, M21, V1, V2, det, m1, m2, Var_a, Var_b, Q0, err_Q0, eta, err_eta
        real, dimension(:), allocatable :: Q, Qe, f, l_Q, l_f, V_l_Q, S_l_Q
	character (len=100) :: fname, dummy
	
	!reading file
        read(*,*)fname
	open(20,file=fname,status='old')
        !reading file length
        read(*,*) file_len
	!variables
	open(30, file='temp4', status='replace')
	allocate (Q(file_len))
	allocate (Qe(file_len))
	allocate (f(file_len))
	allocate (l_f(file_len))
	allocate (l_Q(file_len))
	allocate (V_l_Q(file_len))
	allocate (S_l_Q(file_len))

	do 11 j = 1, file_len
		read(20,*) dummy, Q(j), Qe(j), f(j)
11 	end do
	
	do 12 j = 1, file_len
		l_Q(j) = log(Q(j))
		l_f(j) = log(f(j))
		V_l_Q(j) = (Qe(j)/Q(j))**2.0
		S_l_Q(j) = Qe(j)/Q(j)
		
12 	end do
	open(40, file='temp5', status='replace')
!---------------------------------------------------------------------------------------
!Weighted Linear Regression
	
	M11 = 0.0
	M12 = 0.0
	M22 = 0.0
	M21 = 0.0
	V1 = 0.0
	V2 = 0.0
	
	do 75 j = 1, file_len
		M11 = M11 + (1.0/V_l_Q(j))
		M12 = M12 + l_f(j)/V_l_Q(j)
		M22 = M22 + (l_f(j)*l_f(j))/V_l_Q(j)
		V1 = V1 + l_Q(j)/V_l_Q(j)
		V2 = V2 + (l_f(j)*l_Q(j))/V_l_Q(j)
	
75	end do

	M21 = M12
	det = M11*M22 - M12*M21
	m1 = (M11*V2 - M21*V1)/det
	m2 = (M22*V1 - M12*V2)/det
	!print*, det, "-----", m1, "-------", m
		
	Var_a = M11/ det
	Var_b = M22/ det
	
	do 65 j = 1, file_len
		write(30,*) l_f(j), l_Q(j), m1*l_f(j) + m2, V_l_Q(j), S_l_Q(j)
		!print*, f(j), l_f(j), l_Q(j), m1*l_f(j) + m2, V_l_Q(j), S_l_Q(j)
	
65	end do
	Q0 = exp(m2)
	err_Q0 = exp(m2)*sqrt(Var_b)
	eta = m1
	err_eta = Var_a
	write(40,*) Q0, err_Q0, eta, err_eta, m1, m2, Var_a, Var_b
	close(40)
!------------------------------------------------------------------------------------------
	close(30)
	close(20)
8888    stop
	end program QCalculation



