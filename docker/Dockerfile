FROM r-base:4.1.0
COPY rough_equivalence_check.R /opt/rough_equivalence_check.R
COPY allele_chr1_test.RData /test/allele_chr1_test.RData
COPY allele_chr1_truth.RData /test/allele_chr1_truth.RData
RUN chmod +x /opt/rough_equivalence_check.R
ENV PATH="${PATH}:/opt/"
CMD "/bin/bash"