version 1.0

################################## LICENSE ##################################
# Copyright 2021 Aisling "Ash" O'Farrell
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#       http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################### NOTES ####################################
# Caveat programmator: This runs a real null model workflow ten times
# and downloads about eighty files from a requester-pays GC bucket.
# Furthermore, as this is a simpler version of my null model checker
# workflow, it does not include an R script that accounts for normal
# variance between platforms. As such, this pipeline may (correctly)
# report some md5 mismatches. It is included in this repo as an example
# of calling task-specific output instead of workflow-level output,
# as well as an example of checking a large amount of configurations.

import "https://raw.githubusercontent.com/DataBiosphere/analysis_pipeline_WDL/v3.0.1/null-model/null-model.wdl" as nullmodel
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v0.99.2/checker_tasks/arraycheck_task.wdl" as arraycheck

workflow checker_nullmodel {
	input {

		# run the one known configuration which is likely to error out
		# only useful to brave debuggers; this is likely related to an AWS issue
		Boolean run_conditionalinv = false 

		# commented out variables, included here for clarity,
		# change depending on specific run and are set manually elsewhere
		File? conditional_variant_file
		#Array[String]? covars
		#String family
		Array[File]? gds_files
		String? group_var
		Boolean? inverse_normal
		#Int? n_pcs  
		Boolean? norm_bygroup
		#String outcome
		String? output_prefix
		File? pca_file
		File phenotype_file
		File phenotype_file_alternative
		File? relatedness_matrix_file
		File? relatedness_matrix_file_alternative
		File? relatedness_matrix_file_grm
		String? rescale_variance
		Boolean? resid_covars
		File? sample_include_file_typical
		File? sample_include_file_unrelated

		# truth files
		File truth__Null_model_mixed_nullmodel
		File truth__Null_model_mixed_pheno
		File truth__Null_model_mixed_report
		File truth__basecase_nullmodel
		File truth__basecase_pheno
		File truth__basecase_report
		File truth__basecase_report_invnorm
		File truth__binary_nullmodel
		File truth__binary_pheno
		File truth__binary_report
		File truth__binary_nullmodel
		File truth__conditional_nullmodel
		File truth__conditional_pheno
		File truth__conditional_report

		File truth__conditionalinv_nullmodel_invnorm
		File truth__conditionalinv_report_invnorm
		File truth__conditionalinv_pheno
		File truth__conditionalinv_report
		
		File truth__grm_nullmodel
		File truth__grm_pheno
		File truth__grm_report
		File truth__grm_report_invnorm
		File truth__group_nullmodel
		File truth__group_pheno
		File truth__group_report
		File truth__group_report_invnorm
		File truth__norm_nullmodel
		File truth__norm_pheno
		File truth__norm_report
		File truth__norm_report_invnorm
		File truth__notransform_nullmodel
		File truth__notransform_pheno
		File truth__notransform_report
		File truth__unrelbin_nullmodel
		File truth__unrelbin_pheno
		File truth__unrelbin_report
		File truth__unrelated_nullmodel
		File truth__unrelated_pheno
		File truth__unrelated_report
		File truth__unrelated_report_invnorm
	}

	##############################
	#        SB WS Example       #
	##############################
	call nullmodel.null_model_r as Null_model_mixed__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "age", "study", "PC1", "PC2", "PC3", "PC4", "PC5"],
			family = "gaussian",
			#gds_files =
			group_var = "study",
			inverse_normal = false,
			#n_pcs = 
			#norm_bygroup
			outcome = "height",
			output_prefix = "Null_model_mixed",
			#pca_file = 
			phenotype_file = phenotype_file_alternative,
			relatedness_matrix_file = relatedness_matrix_file_alternative,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call nullmodel.null_model_report as Null_model_mixed__nullmodelreport {
		input:
			null_model_files = Null_model_mixed__nullmodelr.null_model_files,
			null_model_params = Null_model_mixed__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "age", "study", "PC1", "PC2", "PC3", "PC4", "PC5"],
			family = "gaussian",
			#gds_files =
			group_var = "study",
			inverse_normal = false,
			#n_pcs = 
			#norm_bygroup
			output_prefix = "Null_model_mixed",
			#pca_file = 
			phenotype_file = phenotype_file_alternative,
			relatedness_matrix_file = relatedness_matrix_file_alternative,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call arraycheck.arraycheck_classic as Null_model_mixed_md5 {
		input:
			test = [Null_model_mixed__nullmodelr.null_model_files[0], Null_model_mixed__nullmodelr.null_model_phenotypes, Null_model_mixed__nullmodelreport.rmd_files[0]],
			truth = [truth__Null_model_mixed_nullmodel, truth__Null_model_mixed_pheno, truth__Null_model_mixed_report]
	}
	##############################
	#          base case         #
	##############################
	call nullmodel.null_model_r as basecase__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup
			outcome = "outcome",
			output_prefix = "basecase",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call nullmodel.null_model_report as basecase__nullmodelreport {
		input:
			null_model_files = basecase__nullmodelr.null_model_files,
			null_model_params = basecase__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup
			output_prefix = "basecase",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}#
	call arraycheck.arraycheck_classic as basecase_md5 {
		input:
			test = [basecase__nullmodelr.null_model_files[0], basecase__nullmodelr.null_model_phenotypes, basecase__nullmodelreport.rmd_files[0], basecase__nullmodelreport.rmd_files[1]],
			truth = [truth__basecase_nullmodel, truth__basecase_pheno, truth__basecase_report, truth__basecase_report_invnorm]
	}
	##############################
	#           binary           #
	###############################
	call nullmodel.null_model_r as binary__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex"],
			family = "binomial",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "status",
			output_prefix = "binary",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call nullmodel.null_model_report as binary__nullmodelreport {
		input:
			null_model_files = binary__nullmodelr.null_model_files,
			null_model_params = binary__nullmodelr.null_model_params,#
			#conditional_variant_file = 
			covars = ["sex"],
			family = "binomial",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "binary",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call arraycheck.arraycheck_classic as binary_md5 {
		input:
			test = [binary__nullmodelr.null_model_files[0], binary__nullmodelr.null_model_phenotypes, binary__nullmodelreport.rmd_files[0]],
			truth = [truth__binary_nullmodel, truth__binary_pheno, truth__binary_report]
	}
	##############################
	#   conditional one-step     #
	#                            #
	# This one does NOT perform  #
	# the inverse norm step, and #
	# should NOT error out.      #
	##############################
	call nullmodel.null_model_r as conditional__nullmodelr {
		input:
			conditional_variant_file = conditional_variant_file,
			covars = ["sex", "Population"],
			family = "gaussian",
			gds_files = gds_files,
			#group_var = 
			inverse_normal = false,
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "outcome",
			output_prefix = "conditional",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call nullmodel.null_model_report as conditional__nullmodelreport {
		input:
			null_model_files = conditional__nullmodelr.null_model_files,
			null_model_params = conditional__nullmodelr.null_model_params,
			
			conditional_variant_file = conditional_variant_file,
			covars = ["sex", "Population"],
			family = "gaussian",
			gds_files = gds_files,
			#group_var = 
			inverse_normal = false,
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "conditional",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call arraycheck.arraycheck_classic as conditional_md5 {
		input:
			test = [conditional__nullmodelr.null_model_files[0], conditional__nullmodelr.null_model_phenotypes, conditional__nullmodelreport.rmd_files[0]],
			truth = [truth__conditional_nullmodel, truth__conditional_pheno, truth__conditional_report]
	}

	if(run_conditionalinv) {
		##############################
		#   conditional inv norm     #
		#                            #
		# This one DOES perform the  #
		# the inverse norm step, and #
		# MIGHT error out.           #
		##############################
		call nullmodel.null_model_r as conditionalinv__nullmodelr {
			input:
				conditional_variant_file = conditional_variant_file,
				covars = ["sex", "Population"],
				family = "gaussian",
				gds_files = gds_files,
				#group_var = 
				inverse_normal = true,
				n_pcs = 4,
				#norm_bygroup = 
				outcome = "outcome",
				output_prefix = "conditionalinv",
				pca_file = pca_file,
				phenotype_file = phenotype_file,
				relatedness_matrix_file = relatedness_matrix_file,
				#rescale_variance = 
				#resid_covars = 
				sample_include_file = sample_include_file_typical
		}
		call nullmodel.null_model_report as conditionalinv__nullmodelreport {
			input:
				null_model_files = conditionalinv__nullmodelr.null_model_files,
				null_model_params = conditionalinv__nullmodelr.null_model_params,
				
				conditional_variant_file = conditional_variant_file,
				covars = ["sex", "Population"],
				family = "gaussian",
				gds_files = gds_files,
				#group_var = 
				inverse_normal = true,
				n_pcs = 4,
				#norm_bygroup = 
				output_prefix = "conditionalinv",
				pca_file = pca_file,
				phenotype_file = phenotype_file,
				relatedness_matrix_file = relatedness_matrix_file,
				#rescale_variance = 
				#resid_covars = 
				sample_include_file = sample_include_file_typical
		}
		call arraycheck.arraycheck_classic as conditionalinv_md5 {
			input:
				test = [conditionalinv__nullmodelr.null_model_files[0], conditionalinv__nullmodelr.null_model_phenotypes, conditionalinv__nullmodelreport.rmd_files[0], conditionalinv__nullmodelreport.rmd_files[1]],
				truth = [truth__conditionalinv_nullmodel_invnorm, truth__conditionalinv_report_invnorm, truth__conditionalinv_pheno, truth__conditionalinv_report]
		}
	}
	##############################
	#            grm             #
	###############################
	call nullmodel.null_model_r as grm__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files = 
			#group_var = 
			#inverse_normal = 
			n_pcs = 0,
			#norm_bygroup = 
			outcome = "outcome",
			output_prefix = "grm",
			#pca_file = 
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file_grm,
			rescale_variance = "marginal",
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call nullmodel.null_model_report as grm__nullmodelreport {
		input:
			null_model_files = grm__nullmodelr.null_model_files,
			null_model_params = grm__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files = 
			#group_var = 
			#inverse_normal = 
			n_pcs = 0,
			#norm_bygroup = 
			output_prefix = "grm",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file_grm,
			rescale_variance = "marginal",
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call arraycheck.arraycheck_classic as grm_md5 {
		input:
			test = [grm__nullmodelr.null_model_files[0], grm__nullmodelr.null_model_phenotypes, grm__nullmodelreport.rmd_files[0], grm__nullmodelreport.rmd_files[1]],
			truth = [truth__grm_nullmodel, truth__grm_pheno, truth__grm_report, truth__grm_report_invnorm]
	}
	##############################
	#           group            #
	##############################
	call nullmodel.null_model_r as group__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "outcome",
			output_prefix = "group",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call nullmodel.null_model_report as group__nullmodelreport {
		input:
			null_model_files = group__nullmodelr.null_model_files,
			null_model_params = group__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "group",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call arraycheck.arraycheck_classic as group_md5 {
		input:
			test = [group__nullmodelr.null_model_files[0], group__nullmodelr.null_model_phenotypes, group__nullmodelreport.rmd_files[0], group__nullmodelreport.rmd_files[1]],
			truth = [truth__group_nullmodel, truth__group_pheno, truth__group_report, truth__group_report_invnorm]
	}
	##############################
	#        norm bygroup        #
	##############################
	call nullmodel.null_model_r as norm__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			#inverse_normal = 
			n_pcs = 4,
			norm_bygroup = true,
			outcome = "outcome",
			output_prefix = "norm",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call nullmodel.null_model_report as norm__nullmodelreport {
		input:
			null_model_files = norm__nullmodelr.null_model_files,
			null_model_params = norm__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			#inverse_normal = 
			n_pcs = 4,
			norm_bygroup = true,
			output_prefix = "norm",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			#rescale_variance = 
			#resid_covars = 
			#sample_include_file = 
	}
	call arraycheck.arraycheck_classic as norm_md5 {
		input:
			test = [norm__nullmodelr.null_model_files[0], norm__nullmodelr.null_model_phenotypes, norm__nullmodelreport.rmd_files[0], norm__nullmodelreport.rmd_files[1]],
			truth = [truth__norm_nullmodel, truth__norm_pheno, truth__norm_report, truth__norm_report_invnorm]
	}
	##############################
	#        no transform        #
	##############################
	call nullmodel.null_model_r as notransform__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			inverse_normal = false,
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "outcome",
			output_prefix = "notransform",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			rescale_variance = "none",
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call nullmodel.null_model_report as notransform__nullmodelreport {
		input:
			null_model_files = notransform__nullmodelr.null_model_files,
			null_model_params = notransform__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			group_var = "Population",
			inverse_normal = false,
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "notransform",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			relatedness_matrix_file = relatedness_matrix_file,
			rescale_variance = "none",
			#resid_covars = 
			sample_include_file = sample_include_file_typical
	}
	call arraycheck.arraycheck_classic as notransform_md5 {
		input:
			# notransform only have one report
			test = [notransform__nullmodelr.null_model_files[0], notransform__nullmodelr.null_model_phenotypes, notransform__nullmodelreport.rmd_files[0]],
			truth = [truth__notransform_nullmodel, truth__notransform_pheno, truth__notransform_report]
	}
	##############################
	#        unrel binary        #
	##############################
	call nullmodel.null_model_r as unrelbin__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex"],
			family = "binomial",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "status",
			output_prefix = "unrelbin",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			#relatedness_matrix_file = 
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_unrelated
	}
	call nullmodel.null_model_report as unrelbin__nullmodelreport {
		input:
			null_model_files = unrelbin__nullmodelr.null_model_files,
			null_model_params = unrelbin__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex"],
			family = "binomial",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "unrelbin",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			#relatedness_matrix_file = 
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_unrelated
	}
	call arraycheck.arraycheck_classic as unrelbin_md5 {
		input:
			# binary models only have one report
			test = [unrelbin__nullmodelr.null_model_files[0], unrelbin__nullmodelr.null_model_phenotypes, unrelbin__nullmodelreport.rmd_files[0]],
			truth = [truth__unrelbin_nullmodel, truth__unrelbin_pheno, truth__unrelbin_report]
	}
	##############################
	#          unrelated         #
	##############################
	call nullmodel.null_model_r as unrelated__nullmodelr {
		input:
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			outcome = "outcome",
			output_prefix = "unrelated",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			#relatedness_matrix_file = 
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_unrelated
	}
	call nullmodel.null_model_report as unrelated__nullmodelreport {
		input:
			null_model_files = unrelated__nullmodelr.null_model_files,
			null_model_params = unrelated__nullmodelr.null_model_params,
			
			#conditional_variant_file = 
			covars = ["sex", "Population"],
			family = "gaussian",
			#gds_files =
			#group_var = 
			#inverse_normal = 
			n_pcs = 4,
			#norm_bygroup = 
			output_prefix = "unrelated",
			pca_file = pca_file,
			phenotype_file = phenotype_file,
			#relatedness_matrix_file = 
			#rescale_variance = 
			#resid_covars = 
			sample_include_file = sample_include_file_unrelated
	}
	call arraycheck.arraycheck_classic as unrelated_md5 {
		input:
			test = [unrelated__nullmodelr.null_model_files[0], unrelated__nullmodelr.null_model_phenotypes, unrelated__nullmodelreport.rmd_files[0], unrelated__nullmodelreport.rmd_files[1]],
			truth = [truth__unrelated_nullmodel, truth__unrelated_pheno, truth__unrelated_report, truth__unrelated_report_invnorm]
	}


	meta {
		author: "Ash O'Farrell"
		email: "aofarrel@ucsc.edu"
	}
}
