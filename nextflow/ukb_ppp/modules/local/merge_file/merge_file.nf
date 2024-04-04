process MERGE {
  """
  Merges files with names containing "chrX" (where X is 1-22)
  from each subdirectory into a single .txt file
  """

  label 'process_medium'
  
  input:
    tuple val(meta), path(untar_file)

  output:
    tuple val(meta), path("$subdir/merged.txt"), emit: merged

  when:
  task.ext.when == null || task.ext.when  

  script:
    """
    #!/bin/bash
    for subdir in . 
      do zcat \$(find "$subdir" -name "*chr[1-22]*") > "$subdir/merged.txt"
      done
    """
}