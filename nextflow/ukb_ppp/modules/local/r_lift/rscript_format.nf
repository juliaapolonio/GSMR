process R_LIFT {
  """
  Runs an Rscript on the merged .txt file
  """

  label 'process_medium'

  input:
    tuple val(meta), path(merged)

  output:
    tuple val(meta), path("${meta.id}_format.txt"), emit: lifted

  when:
  task.ext.when == null || task.ext.when  

  script:
    """
    #!/bin/bash
    Rscript ~/scripts/r/format_pqtl.R $merged ${meta.id}_format.txt
    """
}

