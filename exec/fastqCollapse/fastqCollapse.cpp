#include <algorithm>
#include <string>
#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
#include <map>
#include <set>
#include <zlib.h>
#include <math.h>




using namespace std;

template <class T>   std::string toString( T value )  { std::ostringstream oss;   oss.precision(3);  oss << value;  return oss.str();}


class parameters {
public:
  string fa1, fa2, output_file, summary_file;
  map<string, pair<int, int> > SNP_to_data;
  
  parameters (const int narg, char ** argc);
};



////////// file used to parse the argument provided to the code
parameters::parameters (const int narg, char ** argc) {

  clock_t c_start = clock();
  
  for (int i = 0; i != narg; i++) cout<<argc[i]<<" "; cout<<endl<<endl;

  summary_file = "default_summary";
  output_file = "default_output";

 ///-------------
  vector<vector<string> > temp;
  vector<string> loc;      
  
  int count = 1;
  while ( count < narg ) {    
    loc.push_back(argc[count]);
    count++;
    if (count == narg) {temp.push_back(loc);break;}
    else {if (argc[count][0] == '-') {temp.push_back(loc);loc.assign(0, "nothing");}}
  }
  

  for (int i = 0; i != temp.size(); i++) {
    bool flag = false;
    if ( temp[i][0] == "-i" ) {
      flag = true;
      if (temp[i].size() != 3) {cerr<<"Needs 2 arguments for -i\n";exit(1);}
      fa1 = temp[i][1];
      fa2 = temp[i][2];
    }

    if ( temp[i][0] == "-o" ) {
      flag = true;
      if (temp[i].size() != 2) {cerr<<"Needs 1 argument for -o\n";exit(1);}
      output_file = temp[i][1];
    }
     
    if ( temp[i][0] == "-summary" ) {
      flag = true;
      if (temp[i].size() != 2) {cerr<<"Needs 1 argument for -summary\n";exit(1);}
      summary_file = temp[i][1];
    }
    if (!flag) {cerr<<"Unknown parameter "<<temp[i][0]<<endl; exit(1);}
  }

}



int main (int narg, char ** argc) {
  clock_t c_start = clock();

  parameters * my_params = new parameters(narg, argc);
  
  cout<<"Fastqcollapser"<<endl;
  cout<<"Filter duplicates from paired end fastq files. If the input format is Illumina fastq, Fastqcollapser will convert the output to Sanger fastq.\n\n";

  cout<<"Options:"<<endl;
  cout<<"-i fastq1 fastq2   so far both files need to be in gzipped format"<<endl;
  cout<<"-o output   will create two output files: output_1.fq output_1.fq"<<endl;
  cout<<"-summary filename.txt creates a summary file"<<endl;
  cout<<"\n\n\n";

  cout<<"Parsing file "<<my_params->fa1<<"  "<<my_params->fa2<<endl;  
  bool compressed = (my_params->fa1.find(".gz") !=  my_params->fa1.npos);

  ifstream inp1, inp2;
  ofstream out1, out2, sumout;
  gzFile my_pointer1, my_pointer2;
  string seq1, q1, seq2, q2, h1, h2;
  int maxline = 1000000;
  char * buf = new char[maxline];
  istringstream instream1, instream2;


  map<string, pair<int, double> > sig_to_nb;
  set<int> selected_counts;
  bool Illumina_to_fastq = false;
  
  
  int min_qual = 1000;  //minimum quality to see if Illumina or Sanger fastq
  for (int parse = 0; parse != 2; parse++) {

    if (compressed) {
      my_pointer1 = gzopen ( my_params->fa1.c_str(), "rb");
      if (my_pointer1 == NULL) {cerr<<"Cannot open: "<<my_params->fa1<<endl;exit(1);}
      
      my_pointer2 = gzopen ( my_params->fa2.c_str(), "rb");
      if (my_pointer2 == NULL) {cerr<<"Cannot open: "<<my_params->fa2<<endl;exit(1);}
    }
    
    if (!compressed) {
      inp1.open( my_params->fa1.c_str());
      if (! inp1.is_open() ) {cerr<<"Cannot open "<<my_params->fa1<<endl; exit(1);}
      
      inp2.open( my_params->fa2.c_str());
      if (! inp2.is_open() ) {cerr<<"Cannot open "<<my_params->fa2<<endl; exit(1);}
    }

    int count = 0, accepted = 0;
    if (parse == 1) {
      out1.open(  (my_params->output_file + "_1.fq").c_str() );
      out2.open(  (my_params->output_file + "_2.fq").c_str() );
      if (min_qual > 63) {
	Illumina_to_fastq = true;
	cout<<"Minimum quality: "<<min_qual<<endl;
	cout<<"Illumina fastq detected, converting to Sanger fastq.\n";
      }
    }

    while (1) {
      

      if (!compressed) {
	getline(inp1, seq1);
	if (inp1.eof()) break;
	
	getline(inp2, seq2);
	if (inp2.eof()) break;
	
	//cout<<inp1<<"  "<<inp2<<endl;exit(1);
      }
      
      if (compressed) {
	
	gzgets(my_pointer1, buf, maxline);  //line1 header      
	h1.assign(buf);
	gzgets(my_pointer1, buf, maxline);   //line 2 seq
	seq1.assign(buf);
	gzgets(my_pointer1, buf, maxline);  //line 3 junk
	gzgets(my_pointer1, buf, maxline);  //line 4 qual
	q1.assign (buf);

	if (gzeof(my_pointer1)) break;
	    
	gzgets(my_pointer2, buf, maxline);  //line1 header      
	h2.assign(buf);
	gzgets(my_pointer2, buf, maxline);   //line 2 seq
	seq2.assign(buf);
	gzgets(my_pointer2, buf, maxline);  //line 3 junk
	gzgets(my_pointer2, buf, maxline);  //line 4 qual
	q2.assign (buf);
	
	if (gzeof(my_pointer2)) break;
      }
      
      
      if (parse == 0) {
	int sig1 = min((int) seq1.size(), 40);
	int sig2 = min((int) seq2.size(), 40);
	

	//----------- determine signature and mean quality
	string my_sig = seq1.substr(0, sig1) + "_" + seq2.substr(0, sig1);
	double mean_qual = 0.;
	for (unsigned int i = 0; i != seq1.size(); i++) mean_qual += (int) q1[i];
	for (unsigned int i = 0; i != seq1.size(); i++) mean_qual += (int) q2[i];
	mean_qual /= q1.size() + q2.size();
	
	if (seq1.size() > 10) {
	  for (unsigned int i = seq1.size()-3; i != seq1.size() - 7; i--) min_qual = min(min_qual, (int) q1[i]); 
	}
	
	if (sig_to_nb.count(my_sig) == 1) {
	  double previous_qual =  sig_to_nb[ my_sig ].second;
	  if (mean_qual > previous_qual) {
	    sig_to_nb[ my_sig ].first <- count;
	    sig_to_nb[ my_sig ].second <- mean_qual;
	  }
	} else {
	  sig_to_nb[ my_sig ] = pair<int, double> (count, mean_qual);
	}
      }
      

      if (parse == 1) {
	
	if (selected_counts.count( count ) == 1) {

	  if (Illumina_to_fastq) {
	    for (int i = 0; i != q1.size() - 1; i++) {q1[i] = (char) (((int) q1[i]) - 31);}
	    for (int i = 0; i != q2.size() - 1; i++) {q2[i] = (char) (((int) q2[i]) - 31);}
	  }
	  
	  out1<<h1<<seq1<<"+\n"<<q1;
	  out2<<h2<<seq2<<"+\n"<<q2;
	  accepted++;
	} 
      }
      
      
      count++;
      if (count % 100000 == 0) cout<<count<<"\n"<<h1<<h2<<endl;
      //if (count == 100000) break;
    }
    
    if (parse == 0) {
      for (map<string, pair<int, double> >::iterator k = sig_to_nb.begin(); k != sig_to_nb.end(); k++) {
	selected_counts.insert( ((*k).second).first);
      }
    }
    
    if (parse == 1) {
      out1.close();
      out2.close();

      sumout.open( my_params->summary_file.c_str());
      sumout<<"Total nb of reads parsed: "<<count<<endl;
      sumout<<"Total nb of reads selected: "<<accepted<<endl;
      sumout<<"Percentage unique: "<<(double) accepted/count<<endl;
      sumout.close();

    }
    
    if (compressed) {
      gzclose(my_pointer1);
      gzclose(my_pointer2);
    }
    
  }
  

  
  
  delete [] buf;    
  clock_t finish = clock();
  cout<<"Time needed, in seconds: "<<(double(finish)-double(c_start))/CLOCKS_PER_SEC<<endl;
}
