version 1.0

workflow UnTarGzWorkflow {
	input {
		Array[String] gcp_storage_locations
        String output_location
	}
  
    call CollectGCPLocations { input: gcp_storage_locations = gcp_storage_locations }
    
    scatter( gcpLoc in collectedLocations ) {
        call UnTarGz { input: gcp_location = gcpLoc, output_location = output_location }
    }
    
    output {
		Array[String] collectedLocations = read_lines(stdout())
	}
}

task CollectGCPLocations {
	input {
		Array[String] gcp_storage_locations
	}
  
	command {
		for gcpLocation in ~{sep=' ' gcp_storage_locations}; do
            gsutil ls gcpLocation
        done
	}
  
	output {
		String output_location = output_location
	}
  
	runtime {    
        docker: "ubuntu:latest"  
    }   
}

task UnTarGz {
	input {
		String gcp_location
        String output_location
	}
  
	command {
		mkdir /tmp
        mkdir /tmp/compressed
        mkdir /tmp/decompressed
    
        gsutil cp gcp_location /tmp/compressed/
        for filename in /tmp/compressed/*.tar.gz; do
            echo "Decompress and unarchiving $filename"
            tar -zxf $filename -C /tmp/decompressed/
        done
        gsutil -m cp -r /tmp/decompressed/ output_location
        rm -rf /tmp/
	}
  
	runtime {    
        docker: "ubuntu:latest"  
    }   
}
