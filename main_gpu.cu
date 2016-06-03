#include "db.cuh"
int main( int argc,char ** argv){

	// argument handling
	if (argc<5){
		fprintf(stderr, "usage: ./sim_cuda <maximum_number_of_threads> <number_of_particles> <simulation_time> <time_step>\n");
		exit(1);
	}
		
	// set the simulation parameters
	const int max_thread = atoi(argv[1]);
	const int N = atoi(argv[2]);	//number of particles
	int blocks = int(N/max_thread)+1;
	int T =atoi(argv[3]) ;		// duration of the simulation
	float dt =atoi(argv[4]);		//time steps
	
	//declare input and output array on the Host
	Particle h_particles[N];
	initial_condition(h_particles, N);
	Particle h_output[N];	
	
	//calculate the size of the arrays to be allocated
	int particles_array_bytes = N * sizeof(Particle);
	int output_array_bytes = particles_array_bytes;

	//declare arrays which will be transfered to the Device
	Particle * d_particles;
	Particle * d_output;
	
	//allocate memory space on the Device
	cudaMalloc((void **) &d_particles,particles_array_bytes);
	cudaMalloc((void **) &d_output,output_array_bytes);		
	
	//Transfer arrays to the Device
	cudaMemcpy(d_particles,h_particles,particles_array_bytes,cudaMemcpyHostToDevice);
	
	// run the kernel with N threads and 1 Blocks
	update_position<<<blocks,N>>>(dt,T,N,d_particles,d_output,max_thread);
	
	//write the solution back to the Host
	cudaMemcpy(h_output,d_output,output_array_bytes,cudaMemcpyDeviceToHost);
	
	//for(int i = 0 ; i < N ; i ++){
	//	std::cout<<h_output[i].get_position()[0]<<","<<h_output[i].get_position()[1]\
	//	<<std::endl;
	//}
	//std::cout<<positions_array_bytes<<std::endl;
	
	cudaFree(d_particles);
	cudaFree(d_output);
	
	return 0;
}