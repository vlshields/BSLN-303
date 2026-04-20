@import "Chumpinate"

// instantiate a Chumpinate package
Package pkg("BSLN303");

// add our metadata here
"Vince Shields" => pkg.authors;

"https://github.com/vlshields/BSLN-303.git" => pkg.homepage;
"https://github.com/vlshields/BSLN-303.git" => pkg.repository;

"A Chugraph UGen that emulates the historical acid synthesizer." => pkg.description;
"MIT" => pkg.license;

["resonant", "UGen", "303","synth","acid"] => pkg.keywords;

// generate json in cwd
"./" => pkg.generatePackageDefinition;

// Use semantic versioning. 
PackageVersion ver("BSLN303", "1.0.0");

// The version of chuck when this project started
"1.5.5.0" => ver.languageVersionMin;

// Because this is a ChucK file (and not a ChuGin, which is a complied
// binary, this package is compatible with any operating systems and
// all CPU architectures.
"any" => ver.os;
"all" => ver.arch;

// add our package's files
ver.addFile("BSLN303.ck");

// add our example, this will be stored in the package's `_examples` directory.
ver.addExampleFile("bsln303-help.ck");