#' @title Square stacked violin plot of gene expression in each identity
#'
#' @description This function is a stacked violin plot optimized to display features expression in a \pkg{Seurat} object in a grid fashion (square) instead of a single column like other stacked violin functions available in other packages, resulting in nicer plots and easier to include in publications.
#'
#' @param seurat_object A \pkg{Seurat} object.
#' @param assay Character. If the \pkg{Seurat} object contains multiple RNA assays, you may specify which one to use (for example 'RNA2' if you have created a second RNA assay you named 'RNA2'. See \href{https://satijalab.org/seurat/articles/seurat5_essential_commands.html#create-seurat-or-assay-objects}{Seurat v5 vignettes} for more information). You may also use another assay such as 'SCT' to pull features expression from.
#' @param layer Character. Formerly known as slot. It is recommended to use 'data'.
#' @param features Character. A vector of features to plot.
#' @param idents Character. A vector with one or several identities names in the active.ident identity to use if you only want those (instead of subsetting your object). If \code{NULL}, all identities will be used.
#' @param scale Logical. If \code{TRUE}, scales the violins to have the same max height between features.
#' @param rotate.axis Logical. If \code{TRUE}, flips the axis, displaying violins vertically instead of horizontally.
#' @param colors Character. A vector of colors to use for the active.ident identity, of same length as the number of identities in the active.ident identity or supplied to the \code{idents} parameter. If \code{NULL}, uses \pkg{Seurat}'s default colors.
#' @param order.idents Character or Numeric. A vector specifying either 'reverse' or the levels (as character or as numeric values corresponding to the indexes) of the active.ident identity to order the cells.
#' @param order.colors Logical. If \code{TRUE}, the colors for the active.ident identity will automatically be ordered according to \code{order.idents}. Ignored if \code{order.idents} = \code{NULL}.
#' @param idents.text.size Numeric. The font size of the identities names. Ignored if \code{show.idents} = \code{FALSE}.
#' @param show.idents Logical. If \code{TRUE}, shows the identities names on the plot.
#' @param features.text.size Numeric. The font size of the features names.
#' @param legend.text.size Numeric. The font size of the legend text. Ignored if \code{show.legend} = \code{FALSE}.
#' @param legend.side Character. The side where the legend will be displayed, either 'left', 'right', 'top' or 'bottom'. Ignored if \code{show.legend} = \code{FALSE}.
#' @param show.legend Logical. If \code{TRUE}, shows the legend.
#' @param ncol Numeric. Number of columns to use. If 'square', will display features in a square grid or as close as possible depending on number of features.
#'
#' @return A ggplot object.
#'
#' @examples
#' \dontshow{
#' suppressWarnings(suppressPackageStartupMessages(library(Seurat)))
#' suppressWarnings(suppressMessages(download.file("https://cf.10xgenomics.com/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz", destfile = "pbmc3k_filtered_gene_bc_matrices.tar.gz")))
#' suppressWarnings(suppressMessages(untar("pbmc3k_filtered_gene_bc_matrices.tar.gz")))
#' pbmc3k = suppressWarnings(suppressMessages(Read10X(data.dir = "filtered_gene_bc_matrices/hg19/")))
#' pbmc = suppressWarnings(suppressMessages(CreateSeuratObject(counts = pbmc3k, project = "pbmc3k", min.cells = 3, min.features = 200)))
#' suppressWarnings(suppressMessages(unlink(c("pbmc3k_filtered_gene_bc_matrices.tar.gz","filtered_gene_bc_matrices"), recursive = TRUE)))
#'
#' pbmc[["percent.mt"]] <- suppressWarnings(suppressMessages(PercentageFeatureSet(pbmc, pattern = "^MT-")))
#'
#' pbmc <- suppressWarnings(suppressMessages(subset(pbmc, subset = nFeature_RNA > 400 &
#'                  nFeature_RNA < 2500 &
#'                  percent.mt < 10)))
#'
#' pbmc <- suppressWarnings(suppressMessages(NormalizeData(pbmc, verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(FindVariableFeatures(pbmc, verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(ScaleData(pbmc, features = rownames(pbmc), verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(RunPCA(pbmc, verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(FindNeighbors(pbmc, dims = 1:10, verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(FindClusters(pbmc, resolution = 0.5, verbose = FALSE)))
#' pbmc <- suppressWarnings(suppressMessages(RunUMAP(pbmc, dims = 1:10, verbose = FALSE)))
#' new.cluster.ids <- c("Naive CD4 T", "CD14+ Mono", "Memory CD4 T",
#'                      "B", "CD8 T", "FCGR3A+ Mono", "NK", "DC")
#' names(new.cluster.ids) <- levels(Idents(pbmc))
#' pbmc <- suppressWarnings(suppressMessages(RenameIdents(pbmc, new.cluster.ids)))
#' }
#' pbmc.markers = c("CCR7", "TCF7", "S100A9", "CD14",
#'                  "CD40LG", "CD2", "CD79A", "TCL1A",
#'                  "CCL5", "CD8A", "CDKN1C", "MS4A4A",
#'                  "GNLY", "GZMB", "FCER1A", "CLEC10A")
#'
#' # Example 1: default parameters
#'
#' Grid_VlnPlot(pbmc,
#'              features = pbmc.markers)
#' @import Seurat
#' @import SeuratObject
#' @import data.table
#' @import ggplot2
#' @import grDevices
#' @export

Grid_VlnPlot = function(seurat_object,
                        assay = "RNA",
                        layer = "data",
                        features,
                        idents = NULL,
                        scale = TRUE,
                        rotate.axis = FALSE,
                        colors = NULL,
                        order.idents = NULL,
                        order.colors = TRUE,
                        idents.text.size = 9,
                        show.idents = FALSE,
                        features.text.size = 11,
                        legend.text.size = 12,
                        legend.side = "bottom",
                        show.legend = TRUE,
                        ncol = "square") {

  ident = NULL

  if (isFALSE(any(Assays(seurat_object) %in% assay))) {
    message("Assay '",assay,"' was not found in the Seurat object, using 'RNA' instead")
    assay = "RNA"
  }

  if (isFALSE(any(Layers(seurat_object[[assay]]) %in% layer))) {
    if (isTRUE(any(Layers(seurat_object[[assay]]) %in% "data"))) {
      message("Layer '",layer,"' was not found in the Seurat object's '",assay,"' assay, using 'data' instead")
      layer = "data"
    }
    else {
      message("Layer '",layer,"' was not found in the Seurat object's '",assay,"' assay, using 'counts' instead")
      layer = "counts"
    }
  }

  ident.1 = levels(Idents(seurat_object))

  if (is.character(idents)) {
    ident.1 = ident.1[ident.1 %in% idents]
    if (length(ident.1) == 0) {
      stop("None of the identities supplied to idents were found")
    }
    if (length(ident.1) < length(idents)) {
      message("The following identities supplied to idents were not found:\n", paste0(setdiff(idents, ident.1), collapse = ", "))
    }
  }
  if (is.character(order.idents) | is.numeric(order.idents)) {
    if (length(order.idents) == length(ident.1)) {
      if (is.character(order.idents)) {
        ident.1 = ident.1[order(match(ident.1, order.idents))]
      }
      else {
        ident.1 = ident.1[order.idents]
      }
    }
    else {
      if (order.idents == "reverse") {
        ident.1 = rev(ident.1)
      }
      else {
        stop("order.idents needs to be 'reverse' or a character/numeric vector of same length as the number of identities")
      }
    }
  }

  DefaultAssay(seurat_object) = assay
  data = suppressWarnings(FetchData(object = seurat_object, vars = c("ident",features), layer = layer))
  if (ncol(data) == 1) {
    stop("None of the features were found or expressed in any cells")
  }
  features.removed = setdiff(features, colnames(data))
  data = data[data$ident %in% ident.1, ]
  data = melt(setDT(data), variable.name = "gene", value.name = "expression", id.vars = 1)
  data$ident = factor(data$ident, levels = ident.1)
  if (!is.character(colors)) {
    SeuratColors = function(n = 6, h = c(0, 360) + 15){
      if ((diff(h) %% 360) < 1) h[2] <- h[2] - 360/n
      hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
    }
    colors = SeuratColors(n = length(ident.1))
  }
  if (isTRUE(order.colors)) {
    if (!is.null(names(colors))) {
      colors = colors[ident.1]
    }
    if (is.character(order.idents)) {
      if (length(order.idents) > 1) {
        names(colors) = ident.1
        colors = colors[order.idents]
      }
      else {
        if (order.idents == "reverse") {
          colors = rev(colors)
        }
      }
    }
  }
  if (ncol == "square") {
    ncol = ceiling(sqrt(length(levels(data$gene))))
  }
  if (isFALSE(rotate.axis)) {
    gg = ggplot(data, aes(y=ident, x=expression, fill=ident)) + geom_violin(scale = "width", trim = T, adjust = 1) +
      labs(y="", x="", fill ="") + theme_bw()  +
      theme(legend.position = legend.side, panel.spacing = unit(0, "lines"), legend.text = element_text(size = legend.text.size),
            axis.text.x=element_blank(), axis.ticks.x=element_blank(), strip.text.x = element_text(size = features.text.size),
            panel.grid = element_blank()) +
      scale_fill_manual(values = colors)
    if (isTRUE(scale)) {
      gg = gg + facet_wrap(~gene, ncol=ncol, scales="free_x")
    }
    else {
      gg = gg + facet_wrap(~gene, ncol=ncol)
    }
  }
  else {
    gg = ggplot(data, aes(y=expression, x=ident, fill=ident)) + geom_violin(scale = "width", trim = T, adjust = 1) +
      labs(y="", x="", fill ="") + theme_bw()  +
      theme(legend.position = legend.side, panel.spacing = unit(0, "lines"), legend.text = element_text(size = legend.text.size),
            axis.text.y=element_blank(), axis.ticks.y=element_blank(), strip.text.x = element_text(size = features.text.size),
            panel.grid = element_blank()) +
      scale_fill_manual(values = colors)
    if (isTRUE(scale)) {
      gg = gg + facet_wrap(~gene, ncol=ncol, scales="free_y")
    }
    else {
      gg = gg + facet_wrap(~gene, ncol=ncol)
    }
  }
  if (isFALSE(show.idents) & isFALSE(rotate.axis)) {
    gg = gg + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
  }
  if (isFALSE(show.idents) & isTRUE(rotate.axis)) {
    gg = gg + theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
  }
  if (isFALSE(show.legend)) {
    gg = gg + theme(legend.position="none")
  }
  return(gg)
}
