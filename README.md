
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RightSeuratTools

<!-- badges: start -->
<!-- badges: end -->

This package is a collection of various tools to facilitate the use of
Seurat objects in R. It is intended to be used in conjunction with the
Seurat package, and is not a standalone package. The package is
currently in development and will be updated regularly with new
functions and improvements, so be sure to check regularly for updates on
this page.

## Installation

    devtools::install_github("Alexis-Varin/RightSeuratTools")

## Right_DietSeurat

### Description

As of Seurat v5 release, Seurat’s DietSeurat() function does not remove
data and scale.data layers, resulting in objects with little to no
reduction in size. This function was created with the purpose to restore
DietSeurat()’s proper behavior until the function is fixed by Seurat’s
dev team, as well as to offer a few new options such as the ability to
subset cells or keep variable features.

### Dependencies

- Seurat version \>= 5.0.0
- SeuratObject version \>= 5.0.0

### Usage

    Right_DietSeurat(
      seurat_object,
      idents = NULL,
      cells = NULL,
      features = NULL,
      dimreducs = NULL,
      graphs = NULL,
      variable.features = FALSE,
      misc = TRUE,
      split.counts.layer = NULL,
      data.layer = FALSE,
      scale.layer = FALSE,
      SCTAssay = FALSE
    )

### Arguments

| Argument               | Definition                                                                                                                                                                                                                                                                                                                                                      |
|------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **seurat_object**      | A Seurat object.                                                                                                                                                                                                                                                                                                                                                |
| **idents**             | Character. A vector with one or several identity names in the meta.data slot to keep in the diet object. If NULL, all identities will be kept.                                                                                                                                                                                                                  |
| **cells**              | Character. A vector with one or several cell barcodes to keep in the diet object. If NULL, all cells will be kept.                                                                                                                                                                                                                                              |
| **features**           | Character. A vector with one or several feature names to keep in the diet object. If NULL, all features will be kept.                                                                                                                                                                                                                                           |
| **dimreducs**          | Character. A vector with one or several reduction names to keep in the diet object. If NULL, all DimReducs will be removed. Note that if you subset features and remove all from which PCs were calculated, the PCA will not be kept even if it is specified in this parameter as the feature.loadings slot will be empty, this is intended behavior.           |
| **graphs**             | Character. A vector with one or several graph names to keep in the diet object. If NULL, all Graphs will be removed.                                                                                                                                                                                                                                            |
| **variable.features**  | Logical. If TRUE, the variable features slot will be kept in the diet object. Note that if you keep only a subset of features, the variable features will also be subset, and if you remove all features from which variable features were determined, the variable features will not be kept even if this parameter is set to TRUE, this is intended behavior. |
| **misc**               | Logical. If TRUE, the misc slot will be kept in the diet object.                                                                                                                                                                                                                                                                                                |
| **split.counts.layer** | Character. The name of the identity to split the counts layers if you need to in your downstream analysis. If NULL, the diet object will have a single counts layer, even if the original object had split counts layers.                                                                                                                                       |
| **data.layer**         | Logical. If TRUE, the data layer of the RNA assay will be kept in the diet object if it is present. As with the counts layer, if there are split data layers, they will be joined into a single data layer unless the split.counts.layer parameter is specified.                                                                                                |
| **scale.layer**        | Logical. If TRUE, the scale.data layer of the RNA assay will be kept in the diet object if it is present. As with the counts layer, if there are split scale.data layers, they will be joined into a single scale.data layer unless the split.counts.layer parameter is specified.                                                                              |
| **SCTAssay**           | Logical. If TRUE, the SCT assay will be kept in the diet object if it is present.                                                                                                                                                                                                                                                                               |

### Output

A Seurat object, hopefully smaller, with class Assay5 RNA assay and
specified layers and slots.

### Examples

    Right_DietSeurat(pbmc_small,
                    idents = c("letter.idents","groups"),
                    features = c("CD3D", "NOSIP", "SAFB2",
                     "CD2", "IL7R", "PIK3IP1", "MAL"),
                    graphs = "RNA_snn",
                    split.counts.layer = "letter.idents")

    Right_DietSeurat(pbmc_small,
                    cells = WhichCells(pbmc_small, idents = c("0","1")),
                    variable.features = TRUE,
                    dimreducs = "pca",
                    data.layer = TRUE)

## Barplot_Cell_Proportion

### Description

This function generates a barplot of the proportion of cells from a
Seurat object.

### Dependencies

- Seurat
- SeuratObject
- ggplot2
- patchwork
- scales
- grDevices

### Usage

    Barplot_Cell_Proportion(
      seurat_object,
      group.by = NULL,
      split.by = NULL,
      colors = NULL,
      order.proportion = NULL,
      order.group = NULL,
      order.split = NULL,
      order.colors = TRUE,
      show.cellsum.label = TRUE,
      cellsum.label.size = 3,
      axis.text.size = 9,
      x.axis.angle = 60,
      y.axis.title.size = 11,
      legend.text.size = 9,
      split.plot.title.size = 24,
      legend = TRUE,
      percent = TRUE,
      nrow = 1,
      unique.group.plot = TRUE,
      unique.split.plot = FALSE
    )

### Arguments

| Argument                  | Definition                                                                                                                              |
|---------------------------|:----------------------------------------------------------------------------------------------------------------------------------------|
| **seurat_object**         | A Seurat object.                                                                                                                        |
| **group.by**              | Character. The name of an identity to group the active ident by into a stacked barplot.                                                 |
| **split.by**              | The name of an identity to split the active ident by into separate ggplot objects.                                                      |
| **colors**                | A vector of colors to be used. Seurat’s default colors will be used if NULL.                                                            |
| **order.proportion**      | Character. A vector specifying either “reverse” or the levels of the active ident to order the cells.                                   |
| **order.group**           | Character. A vector specifying either “reverse” or the levels of the group.by identity to order the cells. Ignored if group.by is NULL. |
| **order.split**           | Character. A vector specifying either “reverse” or the levels of the split.by identity to order the cells. Ignored if split.by is NULL. |
| **order.colors**          | Logical. If TRUE, the colors will automatically be ordered according to order.proportion. Ignored if order.proportion is NULL.          |
| **show.cellsum.label**    | Logical. If TRUE, the sum of cells of each identity will be shown at the top of each bar.                                               |
| **cellsum.label.size**    | Numeric. The size of the cell sum label. Ignored if show.cellsum.label is FALSE.                                                        |
| **axis.text.size**        | Numeric. The size of the x axis identities and y axis cell percent or numbers.                                                          |
| **x.axis.angle**          | Numeric. The angle of the x axis identities.                                                                                            |
| **y.axis.title.size**     | Numeric. The size of the y axis title.                                                                                                  |
| **legend.text.size**      | Numeric. The size of the legend text. Ignored if legend is FALSE.                                                                       |
| **split.plot.title.size** | Numeric. The size of the plot titles. Ignored if split.by is NULL.                                                                      |
| **legend**                | Logical. If TRUE, the legend will be shown at the bottom of the ggplot object or patchwork.                                             |
| **percent**               | Logical. If TRUE, the proportion should be shown as a percentage of total cells for each identity.                                      |
| **nrow**                  | Numeric. The number of rows in the patchwork. Ignored if the function returns a ggplot object.                                          |
| **unique.group.plot**     | Logical. If TRUE, the stacked proportion of cells will be gathered in a single ggplot object.                                           |
| **unique.split.plot**     | Logical. If TRUE, the ggplot objects will be gathered in a single patchwork.                                                            |

### Output

A ggplot object, a list of ggplot objects, a patchwork of ggplot objects
or a list of patchworks of ggplot objects.

## About the Author

Alexis Varin, PhD

Inserm Research Engineer in Bioinformatics Analyses

Inserm UMR Right

Bureau 205, 2ème étage

Bâtiment B3 Médecine

15 Bd Maréchal de Lattre de Tassigny 21000 Dijon, France

<https://linkedin.com/in/alexisvarin/>

<https://umr-right.com/>

## Citation

If you find this package useful and would like to cite it, please find
the citation information below :

TBD
