local cmp = require("cmp")

--- From https://yihui.org/knitr/options/#chunk-options (2021-04-19)
local chunk_opts = {
    {
        word = "eval",
        menu = "TRUE",
        user_data = {
            descr = "Whether to evaluate the code chunk. It can also be a numeric vector to choose which R expression(s) to evaluate, e.g., eval = c(1, 3, 4) will evaluate the first, third, and fourth expressions, and eval = -(4:5) will evaluate all expressions except the fourth and fifth.",
        },
    },
    {
        word = "echo",
        menu = "TRUE",
        user_data = {
            descr = "Whether to display the source code in the output document. Besides TRUE/FALSE, which shows/hides the source code, we can also use a numeric vector to choose which R expression(s) to echo in a chunk, e.g., echo = 2:3 means to echo only the 2nd and 3rd expressions, and echo = -4 means to exclude the 4th expression.",
        },
    },
    {
        word = "results",
        menu = '"markup"',
        user_data = {
            descr = 'Controls how to display the text results. Note that this option only applies to normal text output (not warnings, messages, or errors). The possible values are as follows:\n- \\ markup\\ =  Mark up text output with the appropriate environments depending on the output format.\n- \\ asis\\ =  Write text output as-is, i.e., write the raw text results directly into the output document without any markups.\n- \\ hold\\ =  Hold all pieces of text output in a chunk and flush them to the end of the chunk.\n- "hide" (or "FALSE"): Hide text output.',
        },
    },
    {
        word = "collapse",
        menu = "FALSE",
        user_data = {
            descr = "Whether to, if possible, collapse all the source and output blocks from one code chunk into a single block (by default, they are written to separate blocks). This option only applies to Markdown documents.",
        },
    },
    {
        word = "warning",
        menu = "TRUE",
        user_data = {
            descr = "Whether to preserve warnings (produced by `warning()`) in the output. If FALSE, all warnings will be printed in the console instead of the output document. It can also take numeric values as indices to select a subset of warnings to include in the output. Note that these values reference the indices of the warnings themselves (e.g., 3 means “the third warning thrown from this chunk”) and not the indices of which expressions are allowed to emit warnings.",
        },
    },
    {
        word = "error",
        menu = "TRUE",
        user_data = {
            descr = "Whether to preserve errors (from `stop()`). By default, the code evaluation will not stop even in case of errors! If we want to stop on errors, we need to set this option to FALSE. Note that R Markdown has changed this default value to FALSE. When the chunk option include = FALSE, knitr will stop on error, because it is easy to overlook potential errors in this case (if you understand this caveat and want to ignore potential errors anyway, you may set error = 0).",
        },
    },
    {
        word = "message",
        menu = "TRUE",
        user_data = {
            descr = "Whether to preserve messages emitted by `message()` (similar to the option warning).",
        },
    },
    {
        word = "include",
        menu = "TRUE",
        user_data = {
            descr = "Whether to include the chunk output in the output document. If FALSE, nothing will be written into the output document, but the code is still evaluated and plot files are generated if there are any plots in the chunk, so you can manually insert figures later.",
        },
    },
    {
        word = "strip.white",
        menu = "TRUE",
        user_data = {
            descr = "Whether to remove blank lines in the beginning or end of a source code block in the output.",
        },
    },
    {
        word = "class.output",
        menu = "NULL",
        user_data = {
            descr = 'A vector of class names to be added to the text output blocks. This option only works for HTML output formats in R Markdown. For example, with class.output = c("foo", "bar"), the text output will be placed in <pre class="foo bar"></pre>.',
        },
    },
    {
        word = "class.message",
        menu = "NULL",
        user_data = {
            descr = "Similar to class.output, but applied to messages in R Markdown output. Please see the “Code Decoration” section for class.source, which applies similarly to source code blocks.",
        },
    },
    {
        word = "class.warning",
        menu = "NULL",
        user_data = {
            descr = "Similar to class.output, but applied to warnings in R Markdown output. Please see the “Code Decoration” section for class.source, which applies similarly to source code blocks.",
        },
    },
    {
        word = "class.error",
        menu = "NULL",
        user_data = {
            descr = "Similar to class.output, but applied to errors in R Markdown output. Please see the “Code Decoration” section for class.source, which applies similarly to source code blocks.",
        },
    },
    {
        word = "attr.output",
        menu = "NULL",
        user_data = {
            descr = '(character) Similar to the class.* options, but for specifying arbitrary fenced code block attributes for Pandoc; class.* is a special application of attr.*, e.g., class.source = "numberLines" is equivalent to attr.source = ".numberLines", but attr.source can take arbitrary attribute values.',
        },
    },
    {
        word = "attr.message",
        menu = "NULL",
        user_data = {
            descr = '(character) Similar to the class.* options, but for specifying arbitrary fenced code block attributes for Pandoc; class.* is a special application of attr.*, e.g., class.source = "numberLines" is equivalent to attr.source = ".numberLines", but attr.source can take arbitrary attribute values.',
        },
    },
    {
        word = "attr.warning",
        menu = "NULL",
        user_data = {
            descr = '(character) Similar to the class.* options, but for specifying arbitrary fenced code block attributes for Pandoc; class.* is a special application of attr.*, e.g., class.source = "numberLines" is equivalent to attr.source = ".numberLines", but attr.source can take arbitrary attribute values.',
        },
    },
    {
        word = "attr.error",
        menu = "NULL",
        user_data = {
            descr = '(character) Similar to the class.* options, but for specifying arbitrary fenced code block attributes for Pandoc; class.* is a special application of attr.*, e.g., class.source = "numberLines" is equivalent to attr.source = ".numberLines", but attr.source can take arbitrary attribute values.',
        },
    },
    {
        word = "render",
        menu = "knitr::knit_print",
        user_data = {
            descr = 'A function to print the visible values in a chunk. The value passed to the first argument of this function (i.e., x) is the value evaluated from each expression in the chunk. The list of current chunk options is passed to the argument options. This function is expected to return a character string. For more information, check out the package vignette about custom chunk rendering: vignette("knit_print", package = "knitr").',
        },
    },
    {
        word = "split",
        menu = "FALSE",
        user_data = {
            descr = "Whether to split the output into separate files and include them in LaTeX by \\input{} or HTML by <iframe></iframe>. This option only works for .Rnw, .Rtex, and .Rhtml documents.",
        },
    },
    {
        word = "tidy",
        menu = "FALSE",
        user_data = {
            descr = 'Whether to reformat the R code. Other possible values are as follows:\n- `TRUE` (equivalent to tidy = "formatR"): Call the function `formatR::tidy_source()` to reformat the code.\n- \\ styler\\ = Use `styler::style_text()` to reformat the code.\nA custom function of the form function(code, ...) {} to return the reformatted code.',
        },
    },
    {
        word = "tidy.opts",
        menu = "NULL",
        user_data = {
            descr = 'A list of options to be passed to the function determined by the tidy option, e.g., tidy.opts = list(blank = FALSE, width.cutoff = 60) for tidy = "formatR" to remove blank lines and try to cut the code lines at 60 characters.',
        },
    },
    {
        word = "prompt",
        menu = "FALSE",
        user_data = {
            descr = "Whether to add the prompt characters in the R code. See prompt and continue on the help page ?base::options. Note that adding prompts can make it difficult for readers to copy R code from the output, so prompt = FALSE may be a better choice. This option may not work well when the chunk option engine is not R.",
        },
    },
    {
        word = "comment",
        menu = '"##"',
        user_data = {
            descr = "The prefix to be added before each line of the text output. By default, the text output is commented out by ##, so if readers want to copy and run the source code from the output document, they can select and copy everything from the chunk, since the text output is masked in comments (and will be ignored when running the copied text). Set comment = '' remove the default ##.",
        },
    },
    {
        word = "highlight",
        menu = "TRUE",
        user_data = { descr = "Whether to syntax highlight the source code." },
    },
    {
        word = "class.source",
        menu = "NULL",
        user_data = {
            descr = "(character) Class names for source code blocks in the output document. Similar to the class.* options for output such as class.output.",
        },
    },
    {
        word = "attr.source",
        menu = "NULL",
        user_data = {
            descr = "Attributes for source code blocks. Similar to the attr.* options for output such as attr.output.",
        },
    },
    {
        word = "size",
        menu = '"normalsize"',
        user_data = {
            descr = "Font size of the chunk output from .Rnw documents. See this page for possible sizes.",
        },
    },
    {
        word = "background",
        menu = '"#F7F7F7"',
        user_data = { descr = "Background color of the chunk output of .Rnw documents." },
    },
    {
        word = "indent",
        menu = '""',
        user_data = {
            descr = "(character) A string to be added to each line of the chunk output. Typically it consists of white spaces. This option is assumed to be read-only, and knitr sets its value while parsing the document.",
        },
    },
    {
        word = "cache",
        menu = "FALSE",
        user_data = {
            descr = "Whether to cache a code chunk. When evaluating code chunks for the second time, the cached chunks are skipped (unless they have been modified), but the objects created in these chunks are loaded from previously saved databases (.rdb and .rdx files), and these files are saved when a chunk is evaluated for the first time, or when cached files are not found (e.g., you may have removed them by hand). Note that the filename consists of the chunk label with an MD5 digest of the R code and chunk options of the code chunk, which means any changes in the chunk will produce a different MD5 digest, and hence invalidate the cache. See more information on this page.",
        },
    },
    {
        word = "cache.path",
        menu = '"cache/"',
        user_data = {
            descr = "A prefix to be used to generate the paths of cache files. For R Markdown, the default value is based on the input filename, e.g., the cache paths for the chunk with the label FOO in the file INPUT.Rmd will be of the form INPUT_cache/FOO_*.*.",
        },
    },
    {
        word = "cache.vars",
        menu = "NULL",
        user_data = {
            descr = "A vector of variable names to be saved in the cache database. By default, all variables created in the current chunks are identified and saved, but you may want to manually specify the variables to be saved, because the automatic detection of variables may not be robust, or you may want to save only a subset of variables.",
        },
    },
    {
        word = "cache.globals",
        menu = "NULL",
        user_data = {
            descr = "A vector of the names of variables that are not created from the current chunk. This option is mainly for autodep = TRUE to work more precisely---a chunk B depends on chunk A when any of B’s global variables are A’s local variables. In case the automatic detection of global variables in a chunk fails, you may manually specify the names of global variables via this option.",
        },
    },
    {
        word = "cache.lazy",
        menu = "TRUE",
        user_data = {
            descr = "Whether to `lazyLoad()` or directly `load()` objects. For very large objects, lazyloading may not work, so cache.lazy = FALSE may be desirable.",
        },
    },
    {
        word = "cache.comments",
        menu = "NULL",
        user_data = {
            descr = "If FALSE, changing comments in R code chunks will not invalidate the cache database.",
        },
    },
    {
        word = "cache.rebuild",
        menu = "FALSE",
        user_data = {
            descr = 'If TRUE, reevaluate the chunk even if the cache does not need to be invalidated. This can be useful when you want to conditionally invalidate the cache, e.g., cache.rebuild = !file.exists("some-file") can rebuild the chunk when some-file does not exist.',
        },
    },
    {
        word = "dependson",
        menu = "NULL",
        user_data = {
            descr = "A character vector of chunk labels to specify which other chunks this chunk depends on. This option applies to cached chunks only---sometimes the objects in a cached chunk may depend on other cached chunks, so when other chunks are changed, this chunk must be updated accordingly.If dependson is a numeric vector, it means the indices of chunk labels, e.g., dependson = 1 means this chunk depends on the first chunk in the document, and dependson = c(-1, -2) means it depends on the previous two chunks (negative indices stand for numbers of chunks before this chunk, and note they are always relative to the current chunk). Please note this option does not work when set as a global chunk option via `opts_chunk$set()`; it must be set as a local chunk option.",
        },
    },
    {
        word = "autodep",
        menu = "FALSE",
        user_data = {
            descr = "Whether to analyze dependencies among chunks automatically by detecting global variables in the code (may not be reliable), so dependson does not need to be set explicitly.",
        },
    },
    {
        word = "fig.path",
        menu = '"figure/"',
        user_data = {
            descr = "A prefix to be used to generate figure file paths. fig.path and chunk labels are concatenated to generate the full paths. It may contain a directory like figure/prefix-; the directory will be created if it does not exist.",
        },
    },
    {
        word = "fig.keep",
        menu = '"high"',
        user_data = {
            descr = "How plots in chunks should be kept. Possible values are as follows:\n - \\ high\\ =  Only keep high-level plots (merge low-level changes into high-level plots).\n- \\ none\\ =  Discard all plots.\n- \\ all\\ =  Keep all plots (low-level plot changes may produce new plots).\n- \\ first\\ =  Only keep the first plot.\n- \\ last\\ =  Only keep the last plot.\n- If set to a numeric vector, the values are indices of (low-level) plots to keep.",
        },
    },
    {
        word = "fig.show",
        menu = '"asis"',
        user_data = {
            descr = "How to show/arrange the plots. Possible values are as follows:\n- \\ asis\\ = Show plots exactly in places where they were generated (as if the code were run in an R terminal).\n- \\ hold\\ = Hold all plots and output them at the end of a code chunk.\n- \\ animate\\ = Concatenate all plots into an animation if there are multiple plots in a chunk.\n- \\ hide\\ = Generate plot files but hide them in the output document.",
        },
    },
    {
        word = "dev",
        menu = '"pdf"|"png"',
        user_data = {
            descr = '("pdf" for LaTeX output and "png" for HTML/Markdown; character) The graphical device to generate plot files. All graphics devices in base R and those in Cairo, cairoDevice, svglite, ragg, and tikzDevice are supported, e.g., pdf, png, svg, jpeg, tiff, cairo_pdf, CairoJPEG, CairoPNG, Cairo_pdf, Cairo_png, svglite, ragg_png, tikz, and so on. See names(knitr:::auto_exts) for the full list. Besides these devices, you can also provide a character string that is the name of a function of the form function(filename, width, height). The units for the image size are always inches (even for bitmap devices, in which DPI is used to convert between pixels and inches). The chunk options dev, fig.ext, fig.width, fig.height, and dpi can be vectors (shorter ones will be recycled), e.g., dev = c("pdf", "png") creates a PDF and a PNG file for the same plot.',
        },
    },
    {
        word = "dev.args",
        menu = "NULL",
        user_data = {
            descr = 'More arguments to be passed to the device, e.g., dev.args = list(bg = "yellow", pointsize = 10) for dev = "png". This option depends on the specific device (see the device documentation). When dev contains multiple devices, dev.args can be a list of lists of arguments, and each list of arguments is passed to each individual device, e.g., dev = c("pdf", "tiff"), dev.args = list(pdf = list(colormodel = "cmyk", useDingats = TRUE), tiff = list(compression = "lzw")).',
        },
    },
    {
        word = "fig.ext",
        menu = "NULL",
        user_data = {
            descr = "File extension of the figure output. If NULL, it will be derived from the graphical device; see knitr:::auto_exts for details.",
        },
    },
    {
        word = "dpi",
        menu = "72",
        user_data = {
            descr = "The DPI (dots per inch) for bitmap devices (dpi * inches = pixels).",
        },
    },
    {
        word = "fig.width",
        menu = "7",
        user_data = {
            descr = "Width of the plot (in inches), to be used in the graphics device.",
        },
    },
    {
        word = "fig.height",
        menu = "7",
        user_data = {
            descr = "Height of the plot (in inches), to be used in the graphics device.",
        },
    },
    {
        word = "fig.asp",
        menu = "NULL",
        user_data = {
            descr = "The aspect ratio of the plot, i.e., the ratio of height/width. When fig.asp is specified, the height of a plot (the chunk option fig.height) is calculated from fig.width * fig.asp.",
        },
    },
    {
        word = "fig.dim",
        menu = "NULL",
        user_data = {
            descr = "A numeric vector of length 2 to provide fig.width and fig.height, e.g., fig.dim = c(5, 7) is a shorthand of fig.width = 5, fig.height = 7. If both fig.asp and fig.dim are provided, fig.asp will be ignored (with a warning).",
        },
    },
    {
        word = "out.width",
        menu = "NULL",
        user_data = {
            descr = "Width of the plot in the output document, which can be different with its physical fig.width and fig.height, i.e., plots can be scaled in the output document. Depending on the output format, these two options can take special values. For example, for LaTeX output, they can be .8\\linewidth, 3in, or 8cm; for HTML, they may be 300px. For .",
        },
    },
    {
        word = "out.height",
        menu = "NULL",
        user_data = {
            descr = "Height of the plot in the output document, which can be different with its physical fig.width and fig.height, i.e., plots can be scaled in the output document. Depending on the output format, these two options can take special values. For example, for LaTeX output, they can be .8\\linewidth, 3in, or 8cm; for HTML, they may be 300px. For .",
        },
    },
    {
        word = "out.extra",
        menu = "NULL",
        user_data = {
            descr = "Extra options for figures. It can be an arbitrary string, to be inserted in \\includegraphics[] in LaTeX output (e.g., out.extra = \"angle=90\" to rotate the figure by 90 degrees), or <img /> in HTML output (e.g., out.extra = ''style=\"border:5px solid orange;\"'').",
        },
    },
    {
        word = "fig.retina",
        menu = "1",
        user_data = {
            descr = "This option only applies to HTML output. For Retina displays, setting this option to a ratio (usually 2) will change the chunk option dpi to dpi * fig.retina, and out.width to fig.width * dpi / fig.retina internally. For example, the physical size of an image is doubled, and its display size is halved when fig.retina = 2.",
        },
    },
    {
        word = "resize.width",
        menu = "NULL",
        user_data = {
            descr = "The width to be used in \\resizebox{}{} in LaTeX output. The option is not needed unless you want to resize TikZ graphics, because there is no natural way to do it. However, according to the tikzDevice authors, TikZ graphics are not meant to be resized, to maintain consistency in style with other text in LaTeX. If only one of them is NULL, ! will be used (read the documentation of graphicx if you do not understand this).",
        },
    },
    {
        word = "resize.height",
        menu = "NULL",
        user_data = {
            descr = "The height to be used in \\resizebox{}{} in LaTeX output. The option is not needed unless you want to resize TikZ graphics, because there is no natural way to do it. However, according to the tikzDevice authors, TikZ graphics are not meant to be resized, to maintain consistency in style with other text in LaTeX. If only one of them is NULL, ! will be used (read the documentation of graphicx if you do not understand this).",
        },
    },
    {
        word = "fig.align",
        menu = '"default"',
        user_data = {
            descr = 'Alignment of figures in the output document. Possible values are "default", "left", "right", and "center". The default is not to make any alignment adjustments.',
        },
    },
    {
        word = "fig.link",
        menu = "NULL",
        user_data = { descr = "A link to be added onto the figure." },
    },
    {
        word = "fig.env",
        menu = '"figure"',
        user_data = {
            descr = 'The LaTeX environment for figures, e.g., you may set fig.env = "marginfigure" to get \\begin{marginfigure}. This option requires fig.cap be specified.',
        },
    },
    { word = "fig.cap", menu = "NULL", user_data = { descr = "A figure caption." } },
    {
        word = "fig.alt",
        menu = "NULL",
        user_data = {
            descr = "The alternative text to be used in the alt attribute of the <img> tags of figures in HTML output. By default, the chunk option fig.cap will be used as the alternative text if provided.",
        },
    },
    {
        word = "fig.scap",
        menu = "NULL",
        user_data = {
            descr = "A short caption. This option is only meaningful to LaTeX output. A short caption is inserted in \\caption[], and usually displayed in the “List of Figures” of a PDF document.",
        },
    },
    {
        word = "fig.lp",
        menu = '"fig:"',
        user_data = {
            descr = "A label prefix for the figure label to be inserted in \\label{}. The actual label is made by concatenating this prefix and the chunk label, e.g., the figure label for `{r, foo-plot}` will be `fig:foo-plot` by default.",
        },
    },
    {
        word = "fig.pos",
        menu = '""',
        user_data = {
            descr = "A character string for the figure position arrangement to be used in \\begin{figure}[].",
        },
    },
    {
        word = "fig.subcap",
        menu = "NULL",
        user_data = {
            descr = "Captions for subfigures. When there are multiple plots in a chunk, and neither fig.subcap nor fig.cap is NULL, \\subfloat{} will be used for individual plots (you need to add \\usepackage{subfig} in the preamble).",
        },
    },
    {
        word = "fig.ncol",
        menu = "NULL",
        user_data = {
            descr = "The number of columns of subfigures; see this issue for examples (note that fig.ncol and fig.sep only work for LaTeX output).",
        },
    },
    {
        word = "fig.sep",
        menu = "NULL",
        user_data = {
            descr = 'A character vector of separators to be inserted among subfigures. When fig.ncol is specified, fig.sep defaults to a character vector of which every N-th element is \\newline (where N is the number of columns), e.g., fig.ncol = 2 means fig.sep = c("", "", "\\newline", "", "", "\\newline", "", ...).',
        },
    },
    {
        word = "fig.process",
        menu = "NULL",
        user_data = {
            descr = "A function to post-process figure files. It should take the path of a figure file, and return the (new) path of the figure to be inserted in the output. If the function contains the options argument, the list of chunk options will be passed to this argument.",
        },
    },
    {
        word = "fig.showtext",
        menu = "NULL",
        user_data = {
            descr = "If TRUE, call `showtext::showtext_begin()` before drawing plots. See the documentation of the showtext package for details.",
        },
    },
    {
        word = "external",
        menu = "TRUE",
        user_data = {
            descr = 'Whether to externalize tikz graphics (pre-compile tikz graphics to PDF). It is only used for the `tikz()` device in the tikzDevice package (i.e., when dev="tikz"), and it can save time for LaTeX compilation.',
        },
    },
    {
        word = "sanitize",
        menu = "FALSE",
        user_data = {
            descr = "Whether to sanitize tikz graphics (escape special LaTeX characters). See the documentation of the tikzDevice package.",
        },
    },
    {
        word = "interval",
        menu = "1",
        user_data = {
            descr = "Time interval (number of seconds) between animation frames.",
        },
    },
    {
        word = "animation.hook",
        menu = "knitr::hook_ffmpeg_html",
        user_data = {
            descr = 'A hook function to create animations in HTML output; the default hook uses FFmpeg to convert images to a WebM video. This option can also take a character string "ffmpeg" or "gifski" as a shorthand of the corresponding hook function, e.g., animation.hook = "gifski" means animation.hook = knitr::hook_gifski.',
        },
    },
    {
        word = "aniopts",
        menu = '"controls,loop"',
        user_data = {
            descr = "Extra options for animations; see the documentation of the LaTeX animate package.",
        },
    },
    {
        word = "ffmpeg.bitrate",
        menu = '"1M"',
        user_data = {
            descr = "To be passed to the -b:v argument of FFmpeg to control the quality of WebM videos.",
        },
    },
    {
        word = "ffmpeg.format",
        menu = '"webm"',
        user_data = {
            descr = "The video format of FFmpeg, i.e., the filename extension of the video.",
        },
    },
    {
        word = "code",
        menu = "NULL",
        user_data = {
            descr = 'If provided, it will override the code in the current chunk. This allows us to programmatically insert code into the current chunk. For example, code = readLines("test.R") will use the content of the file test.R as the code for the current chunk.',
        },
    },
    {
        word = "ref.label",
        menu = "NULL",
        user_data = {
            descr = "A character vector of labels of the chunks from which the code of the current chunk is inherited (see the demo for chunk references). If the vector is wrapped in `I()` and the chunk option opts.label is not set, it means that the current chunk will also inherit the chunk options (in addition to the code) of the referenced chunks. See the chunk option opts.label for more information on inheriting chunk options.",
        },
    },
    {
        word = "child",
        menu = "NULL",
        user_data = {
            descr = "A character vector of paths of child documents to be knitted and input into the main document.",
        },
    },
    {
        word = "engine",
        menu = '"R"',
        user_data = {
            descr = "The language name of the code chunk. Possible values can be found in `names(knitr::knit_engines$get())`, e.g., python, sql, julia, bash, and c, etc. The object knitr::knit_engines can be used to set up engines for other languages. The demo page contains examples of different engines.",
        },
    },
    {
        word = "engine.path",
        menu = "NULL",
        user_data = {
            descr = 'The path to the executable of the engine. This option makes it possible to use alternative executables in your system, e.g., the default python may be at /usr/bin/python, and you may set engine.path = "~/anaconda/bin/python" to use a different version of Python. engine.path can also be a list of paths, which makes it possible to set different engine paths for different engines.',
        },
    },
    {
        word = "engine.opts",
        menu = "NULL",
        user_data = {
            descr = "Additional arguments passed to the engines. At the chunk level, the option can be specified as a string or a list of options.",
        },
    },
    {
        word = "opts.label",
        menu = "NULL",
        user_data = {
            descr = "This option provides a mechanism to inherit chunk options from either the option template knitr::opts_template (see ?knitr::opts_template) or other code chunks. It takes a character vector of labels. For each label in the vector, knitr will first try to find chunk options set in knitr::opts_template with this label, and if found, apply these chunk options to the current chunk. Then try to find another code chunk with this label (called the “referenced code chunk”) in the document, and if found, also apply its chunk options to the current chunk. The precedence of chunk options is: local chunk options > referenced code chunk options > knitr::opts_template > knitr::opts_chunk. The special value opts.label = TRUE means opts.label = ref.label, i.e., to inherit chunk options from chunks referenced by the ref.label option.",
        },
    },
    {
        word = "purl",
        menu = "TRUE",
        user_data = {
            descr = "When running `knitr::purl()` to extract source code from a source document, whether to include or exclude a certain code chunk.",
        },
    },
    {
        word = "R.options",
        menu = "NULL",
        user_data = {
            descr = "Local R options for a code chunk. These options are set temporarily via `options()` before the code chunk, and restored after the chunk.",
        },
    },
}

local M = {}

M.get_opts = function()
    local copts = {}
    for _, v in pairs(chunk_opts) do
        table.insert(copts, {
            label = v["word"] .. "=",
            kind = cmp.lsp.CompletionItemKind.Field,
            sortText = "0",
            documentation = {
                kind = cmp.lsp.MarkupKind.Markdown,
                value = v.user_data.descr,
            },
        })
    end
    return copts
end

return M
