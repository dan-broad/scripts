library(glue)

if (length(commandArgs()) != 2) {
  stop("Usage: Rscript run_pileup_and_phase.R <sample_sheet_path> <sample>")
}

args <- commandArgs(trailingOnly = TRUE)

sample_sheet_path <- args[1]
sample <- args[2]
sample_sheet <- read.table(sample_sheet_path, header = TRUE, sep = ",")

bam_file <- sample_sheet[sample_sheet$sample == sample, 'bam']
bam_index_file <- sample_sheet[sample_sheet$sample == sample, 'bam_bai']
barcode_file <- sample_sheet[sample_sheet$sample == sample, 'barcode']

system(glue('gsutil -m cp {bam_file} inputs/{sample}/{sample}.bam'))
bam_file <- glue('inputs/{sample}/{sample}.bam')

system(glue('gsutil -m cp {bam_index_file} inputs/{sample}/{sample}.bam.bai'))
bam_index_file <- glue('inputs/{sample}/{sample}.bam.bai')

if (endsWith(barcode_file, 'gz')) {
    system(glue('gsutil -m cp {barcode_file} inputs/{sample}/{sample}.tsv.gz'))
    system(glue('gunzip {barcode_file}'))
} else {
    system(glue('gsutil -m cp {barcode_file} inputs/{sample}/{sample}.tsv'))
}
barcode_file <- glue('{getwd()}/inputs/{sample}/{sample}.tsv')

args <- c('--label', sample, '--samples', sample, '--bams', bam_file,
         '--barcodes', barcode_file, '--outdir', glue('{getwd()}/outputs/{sample}/'), '--gmap',
         '/Eagle_v2.4.1/tables/genetic_map_hg38_withX.txt.gz', '--snpvcf',
         '/data/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf', '--paneldir',
         '/data/1000G_hg38', '--ncores', '30')

system2(command = "Rscript /numbat/inst/bin/pileup_and_phase.R", args = args, stdout = glue("{sample}_pnp.log"))
