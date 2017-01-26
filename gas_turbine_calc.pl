#script for gas turb 1d calcs
#use strict;
#theta = $T2/$T1
#Hu - удельная теплота сгорания
#P1,T1... - compressor inlet
#P2,T2... - camera inlet
#P3,T3... - turbine inlet
#P4,T4... - nozzle or afterburner inlet
#eta_cam - polnota sgoraniya
#P2,
package GAS_DYN;
{

	sub q
	{
		my ($lambda,$k) = @_;
		if (not defined $k){$k = 1.4};
		my $q1 = $lambda*(($k+1)/2)**(1/($k-1));
		my $q2 = (1-(($k-1)*$lambda**2)/($k+1))**(1/($k-1));
		return $q1*$q2;
	}
	
	sub pi
	{
		my ($lambda,$k) = @_;
		if (not defined $k){$k = 1.4};
		my $pi = (1-(($k-1)*$lambda**2)/($k+1))**($k/($k-1));
		return $pi;
	}
	
	sub tau
	{
		my ($lambda,$k) = @_;
		if (not defined $k){$k = 1.4};
		my $tau = (1-(($k-1)*$lambda**2)/($k+1));
		return $tau;
	}
	
	sub eps
	{
		my ($lambda,$k) = @_;
		if (not defined $k){$k = 1.4};
		my $eps = (1-(($k-1)*$lambda**2)/($k+1))**(1/($k-1));
		return $eps;
	}

}; 

package THERMO;
{

						
	sub calc_velocity
				{
	
					my $params_ref = shift;
					my %par = %{$params_ref};
					return $par{M}*$par{a_atm};
					%par = undef;
				};
				
	sub calc_lambda
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					my $k = $par{k};
				    my $M = $par{M};
					my $lam = sqrt(($k+1)/2)*$M*(1+($k-1)*$M**2/2)**(-0.5);
					return $lam;
				};
				
	sub calc_sigma_intake
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					if ($par{M}<=1)
						{
							return 0.97;
						}else
						{
							return 0.97-0.1*($par{M}-1)**1.5;
						}
				}
	sub calc_compressor_inlet_pressure
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					return $par{P_atm}*$par{sigma_intake}/GAS_DYN::pi($par{lambda},$par{k});
					
				}	
	sub calc_compressor_inlet_temp
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					return $par{T_atm}/GAS_DYN::tau($par{lambda},$par{k});
				}
	sub calc_camera_inlet_pressure
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					return $par{P1}*$par{pi_k};
				}
	sub calc_camera_inlet_temp
				{
					my $params_ref = shift;
					my %par = %{$params_ref};
					return $par{T1}*(1+($par{pi_k}**(($par{k}-1)/$par{k})-1)/$par{eta_comp});
				}
	#otnositelniy
	sub calc_fuel_flow_rate
	{
		
	}
};

package main;
{
sub adiabatic_compression
{
	my $par_hash = shift;
	my %pa = %{$par_hash};
	# print $pi_stage;
	# my $P_2,my $T_2;
	# $T_2 = ;
	# $P_2 = $P1*$pi_stage;
	%results = 
				(
					T2 => $pa{T1}*$pa{pi_k}**(($pa{k}-1)/$pa{k}),
					P2 => $pa{P1}*$pa{pi_k},
				);
				
	return %results;
}

sub cycle_work
{
	my $par_hash = shift;
	my %pa = %{$par_hash};
	
  	$scobka = $pa{theta}*(1-1/$pa{pi_k}**(($pa{k}-1)/$pa{k}))**-($pa{pi_k}**(($pa{k}-1)/$pa{k})-1);
	 # print $scobka;
	$cycle_work = ($pa{k}/($pa{k}-1))*$pa{R}*$pa{T1}*$scobka;
	print "rabota cycla = $cycle_work\n";
	return $cycle_work;
}

%flight_params = (
					M => 0.85,
					H => 11000,
					k => 1.4,
					R => 287.3,
					a_atm => 294.94,
					P_atm => 22611,
					T_atm =>216.5,
					pi_k => 3.2,
					eta_comp => 0.8,
					eta_cam => 0.8,
					eta_turb => 0.85,
					T3 => 1600
					);

%params = (
				P1 => 1,
				T1 => 288,
				k => 1.4,
				R => 287.3,
				pi_k => 3.05,
				Hu =>42914000
			);
%res = adiabatic_compression(\%params);
print "\n\n";

$params{P2} = $res{P2};
$params{T2} = $res{T2};
$params{T3} = 1300;
$params{theta} = $params{T3}/$params{T1};
$params{cycle_work} = cycle_work(\%params);
%res = nul;
foreach $key(keys %params)
		{
			print "$key = $params{$key}\n";
		}
print "pi(0.15)".GAS_DYN::pi(0.15,1.4);
print "\n";
$flight_params{V} = THERMO::calc_velocity(\%flight_params);
$flight_params{lambda} = THERMO::calc_lambda(\%flight_params);
$flight_params{sigma_intake} =THERMO::calc_sigma_intake(\%flight_params);
$flight_params{P1} =THERMO::calc_compressor_inlet_pressure(\%flight_params);
$flight_params{T1} =THERMO::calc_compressor_inlet_temp(\%flight_params);
$flight_params{P2} =THERMO::calc_camera_inlet_pressure(\%flight_params);
$flight_params{T2} =THERMO::calc_camera_inlet_temp(\%flight_params);


print $flight_params{V};
print "\n";
print $flight_params{lambda};
print "\n";
print $flight_params{sigma_intake}."\n";
print $flight_params{P1}."\n";
print $flight_params{T1}."\n";
print $flight_params{P2}."\n";
print $flight_params{T2}."\n";
}