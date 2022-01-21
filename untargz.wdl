version 1.0
workflow UnTarGzWorkflow {
    input {
        Array[String] gcp_src_paths
        Array[String] gcp_dst_paths
    }
    scatter (gcpPaths in zip(gcp_src_paths, gcp_dst_paths)) {
        call UnTarGz { input: gcp_location = gcpPaths.left, output_location = gcpPaths.right }
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
        docker: "google/cloud-sdk:latest"
        preemptible : 2
        disk : "/tmp/ 100 HDD"
    }
}