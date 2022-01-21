version 1.0
workflow UnTarGzWorkflow {
    input {
        Array[String] gcp_storage_locations
        String output_location
    }
    call CollectGCPLocations { input: gcp_storage_locations = gcp_storage_locations }
    scatter( gcpLoc in CollectGCPLocations.collectedLocations ) {
        call UnTarGz { input: gcp_location = gcpLoc, output_location = output_location }
    }
    output {
        String final_location = output_location
    }
}

task CollectGCPLocations {
    input {
        Array[String] gcp_storage_locations
    }
    command {
        for gcpLocation in ~{sep=' ' gcp_storage_locations}; do
            gsutil ls $gcpLocation
        done
    }
    output {
        Array[String] collectedLocations = read_lines(stdout())
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
        test -d /tmp || mkdir /tmp
        test -d /tmp/compressed || mkdir /tmp/compressed
        test -d /tmp/decompressed || mkdir /tmp/decompressed
        echo ~{gcp_location}
        gsutil -m cp ~{gcp_location} /tmp/compressed/
        for filename in /tmp/compressed/*.tar.gz; do
            echo "Decompress and unarchiving $filename"
            tar -zxf $filename -C /tmp/decompressed/
        done
        gsutil -m cp -r /tmp/decompressed/* ~{output_location}
        rm -rf /tmp/compressed
        rm -rf /tmp/decompressed
    }
    runtime {
        docker: "ubuntu:latest"
    }
}