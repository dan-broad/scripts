version 1.0
workflow UnTarGzWorkflow {
    input {
        Array[String] gcp_storage_locations
        String output_location
    }
    call UnTarGz { input: gcp_locations = gcp_storage_locations, output_location = output_location }

    output {
        String final_location = output_location
    }
}

task UnTarGz {
    input {
        Array[String] gcp_locations
        String output_location
    }
    command {
        test -d /tmp || mkdir /tmp
        for gcpLocation in ~{sep=' ' gcp_locations}; do
            test -d /tmp/compressed || mkdir /tmp/compressed
            test -d /tmp/decompressed || mkdir /tmp/decompressed
            echo "Processing $gcp_location"
            gsutil -m cp $gcp_location /tmp/compressed/
            for filename in /tmp/compressed/*.tar.gz; do
                echo "Decompress and unarchiving $filename"
                tar -zxf $filename -C /tmp/decompressed/
            done
            gsutil -m cp -r /tmp/decompressed/* ~{output_location}
            rm -rf /tmp/compressed
            rm -rf /tmp/decompressed
        done
    }
    runtime {
        docker: "google/cloud-sdk:latest"
        preemptible : 2
        disk : "/tmp/ 100 HDD"
    }
}