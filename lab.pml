#define EW 0
#define SN 1
#define WN 2
#define NE 3
#define NUMBER_OF_TRAFFIC_LIGHTS 4
       
mtype = {CAR};
mtype = {GREEN, RED};
chan gen_cars[NUMBER_OF_TRAFFIC_LIGHTS] = [1] of {mtype};  
mtype traffic_lights[NUMBER_OF_TRAFFIC_LIGHTS] = {RED, RED, RED, RED}; 
mtype = {GIVEN};
chan cars_queue = [NUMBER_OF_TRAFFIC_LIGHTS] of {byte};
chan cars_ACK[NUMBER_OF_TRAFFIC_LIGHTS] = [0] of {mtype};     
byte semaphore[NUMBER_OF_TRAFFIC_LIGHTS];   
			
active proctype GenCarsEW() {
	end:do
	:: gen_cars[0] ! CAR
	od
}

active proctype GenCarsSN() {
	end:do
	:: gen_cars[1] ! CAR
	od
}

active proctype GenCarsWN() {
	end:do
	:: gen_cars[2] ! CAR
	od
}

active proctype GenCarsNE() {
	end:do
	:: gen_cars[3] ! CAR
	od
}

active proctype Intersection() {
	byte id;
	do
	:: cars_queue ? id ->
		(semaphore[id] == 0);
		if
		:: id == EW ->
			semaphore[SN]++; 
			semaphore[WN]++;
			semaphore[NE]++;
		:: id == SN -> 
			semaphore[EW]++; 
			semaphore[NE]++;
		:: id == WN ->
			semaphore[EW]++; 
			semaphore[NE]++; 
		:: id == NE ->
			semaphore[SN]++; 
			semaphore[EW]++;
			semaphore[WN]++;
		fi
		cars_ACK[id] ! GIVEN;
	od
}
 
active proctype TrafficLightEW() {
	do
	:: gen_cars[EW] ? [CAR] ->
		cars_queue ! EW;
		cars_ACK[EW] ? GIVEN;
		traffic_lights[EW] = GREEN;
		gen_cars[EW] ? CAR;
		printf("Car has passed");
		traffic_lights[EW] = RED;
		d_step {
			semaphore[SN]--; 
			semaphore[WN]--;
			semaphore[NE]--;
		}
	od
}

active proctype TrafficLightSN() {
	do
	:: gen_cars[SN] ? [CAR] ->
		cars_queue ! SN;
		cars_ACK[SN] ? GIVEN;
		traffic_lights[SN] = GREEN;
		gen_cars[SN] ? CAR;
		printf("Car has passed");
		traffic_lights[SN] = RED;
		d_step {
			semaphore[EW]--; 
			semaphore[NE]--;
		}
	od
}

active proctype TrafficLightWN() {
	do
	:: gen_cars[WN] ? [CAR] ->
		cars_queue ! WN;
		cars_ACK[WN] ? GIVEN;
		traffic_lights[WN] = GREEN;
		gen_cars[WN] ? CAR;
		printf("Car has passed");
		traffic_lights[WN] = RED;
		d_step {
			semaphore[EW]--; 
			semaphore[NE]--;
		}
	od
}

active proctype TrafficLightNE() {
	do
	:: gen_cars[NE] ? [CAR] ->
		cars_queue ! NE;
		cars_ACK[NE] ? GIVEN;
		traffic_lights[NE] = GREEN;
		gen_cars[NE] ? CAR;
		printf("Car has passed");
		traffic_lights[NE] = RED;
		d_step {
			semaphore[SN]--; 
			semaphore[EW]--; 
			semaphore[WN]--;
		}
	od
}
 


ltl safety {
	 []!(traffic_lights[1] == GREEN && traffic_lights[3] == GREEN) &&
	 []!(traffic_lights[0] == GREEN && traffic_lights[1] == GREEN) &&
	 []!(traffic_lights[0] == GREEN && traffic_lights[2] == GREEN) &&
	 []!(traffic_lights[0] == GREEN && traffic_lights[3] == GREEN) &&
	 []!(traffic_lights[2] == GREEN && traffic_lights[3] == GREEN)
}

ltl liveness0 { [] ((gen_cars[0]) == CAR && traffic_lights[0] == RED)-> <> (traffic_lights[0] == GREEN) }
ltl liveness1 { [] ((gen_cars[1]) == CAR && traffic_lights[1] == RED )-> <> (traffic_lights[1] == GREEN) }
ltl liveness2 { [] ((gen_cars[2]) == CAR && traffic_lights[2] == RED)-> <> (traffic_lights[2] == GREEN) }
ltl liveness3 { [] ((gen_cars[3]) == CAR && traffic_lights[3] == RED)-> <> (traffic_lights[3] == GREEN) }


ltl fairness1 { 
	[] <> (traffic_lights[0] == GREEN && (gen_cars[0]) == CAR) 
}
ltl fairness { 
	[] <> (traffic_lights[0] == GREEN && (gen_cars[0]) == CAR) &&
 	[] <> !(traffic_lights[1] == GREEN && (gen_cars[1]) == CAR) &&
 	[] <> !(traffic_lights[2] == GREEN && (gen_cars[2]) == CAR) &&
 	[] <> !(traffic_lights[3] == GREEN && (gen_cars[3]) == CAR) 
}
