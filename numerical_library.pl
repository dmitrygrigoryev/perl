#different numerical methods
#MATRIX ALGEBRA

package CONSTANTS;
{
	sub pi{3.1415926535897932384626433832795};
	sub e{2.7182818284590452353602874713527};
} 
package MATRIX_ALGEBRA;
{
		sub matrixE
		{
			$n = shift;
			my($i,$j);
			my @ematrix;
			for ($i = 0;$i<$n;$i++)
				{
					for ($j=0;$j<$n;$j++)
					{
						if($i == $j)
							{$ematrix[$i][$j] = 1}else {$ematrix[$i][$j] = 0}
					}
				}
			return \@ematrix;
		}

		sub matrix_muliply
		{
			my ($a_ref,$b_ref) = @_;
			my @a,@b,@res;
			my($i,$j,$r);
			@a = @{$a_ref}; 
			@b = @{$b_ref};
			@res = ();
			#oboznacheniya iz wiki
			$m = scalar(@{$a[0]});#elements in row for first matrix
			$n = scalar(@a);
			$q = scalar(@b);#elements in column in second matrix
			for ($i= 0;$i<$m;$i++)
				{
					for($j= 0;$j<$q;$j++)
					{
						for($r=0;$r<$n;$r++)
							{
								$res[$i][$j] +=$a[$i][$r]*$b[$r][$j];
							}
					}
				}
				
			for $row(@res)
				{
					print "@$row\n";
				}	
			print "$m\n$n\n$q\n";
			return \@res;
		}

		sub transpose
		{
			$ref = shift;
			@matrix = @{$ref};	
			@res = ();
			$m = scalar(@matrix);
			$n = scalar(@{$matrix[0]});
			for ($i =0; $i<$n; $i++)
				{
					for ($j=0;$j<$m;$j++)
						{
							$res[$i][$j] = $matrix[$j][$i];
						}
				}
			return \@res;
			
		}
		
		sub det
		{
			my $a_ref = shift;
			my @a = @{$a_ref};
			 for ($k=0;$k<$n-1;$k++)
			{
				for($i=$k+1;$i<$n;$i++)
				{
					$t_ik = $a[$i][$k]/$a[$k][$k];
					for($j=$k;$j<$n;$j++)
					{
						$a[$i][$j] = $a[$i][$j] - $t_ik*$a[$k][$j];
						if (abs($a[$i][$j])<1e-15)
							{
								$a[$i][$j] = 0;
							}
					}
				}
			}
			$DetA = 1;
			for ($i=0;$i<$n;$i++)
			{
				$DetA *= $a[$i][$i];
			}
			return $DetA;
		}
		
		sub	inverse_matrix
			{#ne do konza rabotaet
				my $a_ref = shift;
				my @ematrix;
				my @a = @{$a_ref};

			}
}
package LINEAR_EQUATION;
{
		sub gauss($$)
		{
		# plans maximize main diagonal
		my ($a_ref,$b_ref) = @_;
		 my @a = @{$a_ref};
		 my @b = @{$b_ref};
		 $n = @a;
		 #prymoi hod
		 my @x;
		 for ($k=0;$k<$n-1;$k++)
			{

				for($i=$k+1;$i<$n;$i++)
				{
					$t_ik = $a[$i][$k]/$a[$k][$k];
					$b[$i] = $b[$i]-$t_ik*$b[$k];
					
					for($j=$k;$j<$n;$j++)
					{
						$a[$i][$j] = $a[$i][$j] - $t_ik*$a[$k][$j];
						if (abs($a[$i][$j])<1e-15)
							{
								$a[$i][$j] = 0;
							}
					}
				}
			}
		 #obratniy hod
		 $x[$n-1] = $b[$n-1]/$a[$n-1][$n-1];
		 for ($k = $n-2;$k>=0;$k--)
			{
				$sum=0;
				for ($j=$k;$j<$n;$j++)
				{
					$sum =$sum+$a[$k][$j]*$x[$j]; 
				}
				$x[$k] = ($b[$k]-$sum)/$a[$k][$k];
			} 
		 
		 return \@x;
		 
		 }


		sub TDMA
		{
			my ($a_ref,$b_ref) = @_;
			my  @x,@b,@p,@q;
			@a= @{$a_ref};
			@b = @{$b_ref};
			my $i,my $n;
			$n = scalar(@a);		
				$p[0] = $a[0][0];
				$q[0] = $b[0]/$a[0][0];
				for ($i=1;$i<$n;$i++)
				{
					$p[$i] = $a[$i][$i] - ($a[$i][$i-1]*$a[$i-1][$i])/$p[$i-1];
					$q[$i] = ($b[$i]-$a[$i][$i-1]*$q[$i-1])/$p[$i];
				}
				$x[$n-1] = $q[$n-1];
				for($i = $n-2;$i>=0;$i--)
					{
						$x[$i] = $q[$i] - $a[$i][$i+1]*$x[$i+1]/$p[$i];
					}
			return \@x;	
		}
}


package CALCULUS;
{ 
 use Math::Complex;
 use Math::Trig;
 sub complex_circle
	{
		my ($radius,$phi0,$phi1,$step,$z0) = @_;
		# my $n = ($phi1 - $phi0)/$step;
		@z = ();
		$e = CONSTANTS->e;
		my $i;
		 open OUT,  ">C:\\grigorev_dv\\Scripts\\complex_circle.txt";
		for($i = $phi0;$i<=$phi1;$i+=$step)
			{
				$a = $radius*$e**(i*$i)+$z0;
				print OUT Re($a).";".Im($a)."\n";
				# print "\n";
				push @z,$a; 
			}
	close(OUT);
		return \@z;
	}
	
 sub Joukowsky_transform
	{
		my($ref,$radius,$filename) = @_;
		print "FILENAME = $filename";
		my @res = ();
		my @z = @{$ref};
		# print join "\n",@z;
		open OUT, ">$filename";
		for ($i = 0;$i<$#z;$i++)
			{
				$r = ($z[$i]+($radius**2)/$z[$i]);
				print OUT Re($r).";".Im($r)."\n";
				push @res,$r;
				
			}
		print "\n$#z";
		close(OUT);
		# return \@res;
	}
	
	sub Karman_Treftz_transform
	{
		my($ref,$radius,$ang,$filename) = @_;
		print "FILENAME = $filename";
		my @z = @{$ref};
		my @res = ();
		$n = 2 - deg2rad($ang)/CONSTANTS->pi;
		print "n = $n\n\n";
		open OUT, ">$filename";
		for($i=0;$i<=$#z;$i++)
			{
				$a1 =  (1+1/$z[$i])**$n;
				$a2 =  (1-1/$z[$i])**$n;
				$r2 =  $n*($a1+$a2)/($a1-$a2);
				print OUT Re($r2)."	".Im($r2)."	0\n";
				push @res,$r2;
				
			}
		close(OUT);
		# print join "\n",@z;
	}
	
};
package main;
{
use Math::Complex;
@dfs = ([1,2,3],[3,2,1]);
#reading matrices #for test
open LEFT, "<C:\\grigorev_dv\\Scripts\\left_matrix.txt";
open RIGHT, "<C:\\grigorev_dv\\Scripts\\right_matrix.txt";
$i = 0;
while (<LEFT>)
{
	# print "$_\n";
	if ( $_ eq "\n")
	{
		next;
	}else{
			@tmp = split " ",$_;
			push @left, [@tmp];
			}

	# print @tmp;
}

while (<RIGHT>)
{
	# print "$_\n";
	chomp($_);
	if ( $_ eq "\n")
	{
		next;
	}else{
			@tmp = split " ",$_;
			push @right, $_;
			}
	
	# print @tmp;
}
@ll = @{MATRIX_ALGEBRA::transpose(\@{MATRIX_ALGEBRA::transpose(\@left)})};
  @x_tdma =@{LINEAR_EQUATION::TDMA(\@left,\@right)};
  @x_res = @{LINEAR_EQUATION::gauss(\@left,\@right)};

print join "\n",@x_res;
print "\nTDMA\n";
print join "\n",@x_tdma;

  # for ($i=0;$i<5;$i++)
	# {
		# $tst = cplx(-0.5*$i**2,0.5*$i**2);
		# @z = CALCULUS::complex_circle($i+0.1,0,6.283,0.05,$tst);
		# $fn = "C:\\grigorev_dv\\Scripts\\complex_wingrad$i.txt";
		 # CALCULUS::Joukowsky_transform(@z,$fn);
	 # }
		$tst = cplx(-0.08,0.08);
		@z = CALCULUS::complex_circle(1.1,0,6.283,0.05,$tst);
		$fn = "C:\\grigorev_dv\\Scripts\\complex_wingJoukowsky.txt";
		 CALCULUS::Joukowsky_transform(@z,3.1,$fn);
		 CALCULUS::Karman_Treftz_transform(@z,1,5,"C:\\grigorev_dv\\Scripts\\complex_wingKarman.txt");
 close(LEFT);
 close(RIGHT);
}
