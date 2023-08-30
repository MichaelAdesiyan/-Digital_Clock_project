library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clock_sum is
port( inputa,inputb,inputc,inputd,inpute,inputf,inputg:in integer:=0;
		outputmin1,outputmin2,outputhour1,outputhour2:out integer
		);

end entity clock_sum;

architecture clock of clock_sum is
procedure compute_hours(variable hour1in,hour2in: in integer;signal hour1,hour2:out integer) is
	variable h1,h2:integer;
	begin
		h1:=hour1in;h2:=hour2in;
		
		if h2=1 and h1>9 then
			h2:=h2+1;
			h1:=0;
		elsif h2=2 and h1>3 then
			h2:=0;
			h1:=0;
		end if;
		hour1<=h1;hour2<=h2;
	end procedure;
	
	procedure compute_minutes(variable min1in,min2in: in integer;signal min1,min2:out integer) is
		variable m1,m2:integer;
	begin
		m1:=min1in;m2:=min2in;
		min1<=min1in;
		if (m1>9) then
			m1:=0;
			m2:=m2+1;
			if(m2>=5) then
				min2<=min2in;
				m2:=0;
			end if;
		end if;
	end procedure;
	--signal hour_signal: std_logic:='1';
	signal min1,min2,hour1,hour2:integer:=0;
begin
	minute:process(inputa,inputb,inpute,inputg)
		variable detcnt,cnt,min1in,min2in:integer:=0;
	begin
		if detcnt=0 and inputg=30 then
			min1in:=inputa+inputb;
			min2in:=inpute;
			detcnt:=detcnt+1;
		elsif inputg=30 then
			compute_minutes(min1in,min2in,min1,min2);
			if min1in>9 then
				min1in:=0;
			end if;
			
		else
			detcnt:=0;
			min1<=inputb;
			min2<=inpute;
			
		end if;
	end process;
	
	hour:process(inputc,inputd,inputf,inputg)
		variable detcnt, cnt,hour1in,hour2in:integer:=0;
	begin
		if detcnt=0 and inputg=30 then
			hour1in:=inputc+inputd;
			hour2in:=inputf;
			detcnt:=detcnt+1;
		elsif inputg=30 then
			compute_hours(hour1in,hour2in,hour1,hour2);
			
		else
			hour1<=inputd;
			hour2<=inputf;
			detcnt:=0;
		end if;
	end process;
	
	outputmin1<=min1;outputmin2<=min2;outputhour1<=hour1;outputhour2<=hour2;
end architecture clock;