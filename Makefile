# This Makefile is maintained manually

include Makefile.options

BIN     = bin/
OBJ     = obj/
SRC     = src/
SHOWSRC = src/show/
GRIDSRC = src/grid/
PMDSRC  = src/pmd/
APSSRC  = src/sift/autopano-sift-c/
DOC     = doc/

TARGETS = $(BIN)slam6D $(BIN)scan_io_uos.so $(BIN)scan_io_rxp.so $(BIN)scan_io_uos_map.so $(BIN)scan_io_uos_frames.so $(BIN)scan_io_uos_map_frames.so $(BIN)scan_io_old.so $(BIN)scan_io_x3d.so $(BIN)scan_io_asc.so $(BIN)scan_io_rts.so $(BIN)scan_io_iais.so $(BIN)scan_io_rts_map.so $(BIN)scan_io_front.so $(BIN)scan_io_riegl_txt.so $(BIN)scan_io_riegl_bin.so $(BIN)scan_io_zuf.so $(BIN)scan_io_xyz.so $(BIN)scan_io_ifp.so $(BIN)scan_io_ply.so $(BIN)scan_io_wrl.so $(BIN)scan_io_zahn.so 

ifdef WITH_SCANRED
TARGETS += $(BIN)scan_red
endif

ifdef WITH_SHOW
TARGETS += $(BIN)show
endif

ifdef WITH_GRIDDER
TARGETS += $(BIN)2DGridder
endif

ifdef WITH_TOOLS
TARGETS += $(BIN)convergence $(BIN)frame_to_graph $(BIN)graph_balancer 
endif

ifdef WITH_PMD
TARGETS += $(BIN)grabVideoAnd3D $(BIN)grabFramesCam $(BIN)grabFramesPMD $(BIN)convertToSLAM6D $(BIN)calibrate $(BIN)extrinsic $(BIN)pose
endif

ifdef WITH_SIFT
TARGETS += $(OBJ)libANN.a $(BIN)autopano $(BIN)autopano-sift-c 
endif


all: $(TARGETS)

it:
	@echo
	@echo "Tag 'it:' shouldn't be needed if the Makefile were correct... :-)"
	@echo
	make clean && make

docu: docu_html docu_latex docu_hl
	echo
	echo
	echo + Reference documentation generated: $(DOC)html/index.html
	echo + Reference documentation generated: $(DOC)refman.pdf
	echo + Highlevel documentation generated: $(DOC)documentation_HL.pdf
	echo

############# SLAM6D ##############

$(BIN)slam6D: $(OBJ)scanlib.a $(OBJ)icp6D.o $(OBJ)graphSlam6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dsvd.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dhelix.o $(OBJ)gapx6D.o $(OBJ)ghelix6DQ2.o $(OBJ)lum6Deuler.o $(OBJ)lum6Dquat.o $(OBJ)graph.o $(SRC)slam6D.cc $(SRC)globals.icc $(OBJ)csparse.o $(OBJ)libnewmat.a $(OBJ)elch6D.o $(OBJ)elch6Dquat.o $(OBJ)elch6DunitQuat.o $(OBJ)elch6Dslerp.o $(OBJ)elch6Deuler.o
	echo Compiling and Linking SLAM 6D ...
	$(GPP) $(CFLAGS) -o $(BIN)slam6D $(SRC)slam6D.cc $(OBJ)scanlib.a $(OBJ)icp6D.o $(OBJ)gapx6D.o $(OBJ)ghelix6DQ2.o $(OBJ)lum6Deuler.o $(OBJ)lum6Dquat.o $(OBJ)graphSlam6D.o $(OBJ)graph.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dsvd.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dhelix.o $(OBJ)csparse.o $(OBJ)libnewmat.a $(OBJ)elch6D.o $(OBJ)elch6Dquat.o $(OBJ)elch6DunitQuat.o $(OBJ)elch6Dslerp.o $(OBJ)elch6Deuler.o -ldl 
	echo DONE
	echo

$(OBJ)kdc.o: $(SRC)kdcache.h $(SRC)searchCache.h $(SRC)searchTree.h $(SRC)kdc.h $(SRC)kdc.cc $(SRC)globals.icc
	echo Compiling KD tree with cache...
	$(GPP) $(CFLAGS) -c -o $(OBJ)kdc.o $(SRC)kdc.cc 

$(OBJ)kd.o: $(SRC)searchTree.h $(SRC)kd.h $(SRC)kd.cc $(SRC)globals.icc
	echo Compiling KD tree ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)kd.o $(SRC)kd.cc 

$(OBJ)octtree.o: $(SRC)octtree.h $(SRC)octtree.cc $(SRC)globals.icc
	echo Compiling Octree ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)octtree.o $(SRC)octtree.cc 

$(OBJ)d2tree.o: $(SRC)d2tree.h $(SRC)d2tree.cc $(SRC)searchTree.h $(SRC)globals.icc
	echo Compiling D2tree ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)d2tree.o $(SRC)d2tree.cc 

$(OBJ)scan.o: $(SRC)octtree.h $(SRC)kd.h $(SRC)kdc.h $(SRC)kdcache.h $(SRC)scan.h $(SRC)scan_io.h $(SRC)scan.cc $(SRC)scan.icc $(SRC)globals.icc $(SRC)point.h $(SRC)ptpair.h $(SRC)point.icc $(SRC)d2tree.h
	echo Compiling Scan ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)scan.o $(SRC)scan.cc 

$(OBJ)scanlib.a: $(OBJ)octtree.o $(OBJ)kd.o $(OBJ)kdc.o $(OBJ)scan.o $(OBJ)d2tree.o $(OBJ)octtree.o
	echo Linking Scanlib ...
	$(AR) -cr $(OBJ)scanlib.a $(OBJ)scan.o $(OBJ)octtree.o $(OBJ)kd.o $(OBJ)kdc.o $(OBJ)d2tree.o
	ranlib $(OBJ)scanlib.a

$(OBJ)icp6D.o: $(SRC)kd.h $(SRC)kdc.h $(SRC)scan.h $(SRC)icp6D.h $(SRC)icp6D.cc $(SRC)ptpair.h $(SRC)globals.icc $(SRC)icp6Dminimizer.h $(SRC)newmat/newmat.h
	echo Compiling ICP 6D ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6D.o $(SRC)icp6D.cc 

$(OBJ)graphSlam6D.o: $(SRC)icp6D.h $(SRC)graph.h $(SRC)globals.icc $(SRC)graphSlam6D.h $(SRC)graphSlam6D.cc $(SRC)newmat/newmat.h $(SRC)sparse/csparse.h
	echo Compiling GraphSlam6D ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)graphSlam6D.o $(SRC)graphSlam6D.cc

$(OBJ)gapx6D.o: $(SRC)icp6D.h $(SRC)graph.h $(SRC)globals.icc $(SRC)gapx6D.cc $(SRC)gapx6D.h $(SRC)graphSlam6D.h $(SRC)newmat/newmat.h $(SRC)sparse/csparse.h
	echo Compiling Global APX 6D ...
	$(GPP) $(CFLAGS) -DUSE_C_SPARSE -c -o $(OBJ)gapx6D.o $(SRC)gapx6D.cc 

$(OBJ)ghelix6DQ2.o: $(SRC)icp6D.h $(SRC)graph.h $(SRC)globals.icc $(SRC)ghelix6DQ2.cc $(SRC)ghelix6DQ2.h $(SRC)graphSlam6D.h $(SRC)newmat/newmat.h $(SRC)sparse/csparse.h
	echo Compiling global HELIX 6D Q2 ...
	$(GPP) $(CFLAGS) -DUSE_C_SPARSE -c -o $(OBJ)ghelix6DQ2.o $(SRC)ghelix6DQ2.cc 

$(OBJ)lum6Deuler.o: $(SRC)icp6D.h $(SRC)graph.h $(SRC)globals.icc $(SRC)lum6Deuler.h $(SRC)lum6Deuler.cc $(SRC)graphSlam6D.h $(SRC)newmat/newmat.h $(SRC)sparse/csparse.h
	echo Compiling LUM 6D Euler  ...
	$(GPP) $(CFLAGS) -DUSE_C_SPARSE -c -o $(OBJ)lum6Deuler.o $(SRC)lum6Deuler.cc 

$(OBJ)lum6Dquat.o: $(SRC)icp6D.h $(SRC)graph.h $(SRC)globals.icc $(SRC)lum6Dquat.h $(SRC)lum6Dquat.cc $(SRC)graphSlam6D.h $(SRC)newmat/newmat.h $(SRC)sparse/csparse.h
	echo Compiling LUM 6D Quaternion ...
	$(GPP) $(CFLAGS) -DUSE_C_SPARSE -c -o $(OBJ)lum6Dquat.o $(SRC)lum6Dquat.cc 

$(OBJ)elch6D.o: $(SRC)elch6D.cc $(SRC)elch6D.h $(SRC)loopSlam6D.h $(SRC)icp6D.h $(SRC)icp6Dminimizer.h $(SRC)scan.h $(SRC)graph.h $(SRC)globals.icc
	echo Compiling ELCH 6D ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)elch6D.o $(SRC)elch6D.cc 

$(OBJ)elch6Deuler.o: $(SRC)elch6Deuler.cc $(SRC)elch6Deuler.h $(SRC)elch6D.h $(SRC)loopSlam6D.h $(SRC)icp6D.h $(SRC)icp6Dminimizer.h $(SRC)scan.h $(SRC)graph.h $(SRC)lum6Deuler.h
	echo Compiling ELCH 6D Euler ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)elch6Deuler.o $(SRC)elch6Deuler.cc 

$(OBJ)elch6Dquat.o: $(SRC)elch6Dquat.cc $(SRC)elch6Dquat.h $(SRC)elch6D.h $(SRC)loopSlam6D.h $(SRC)icp6D.h $(SRC)icp6Dminimizer.h $(SRC)scan.h $(SRC)graph.h $(SRC)lum6Dquat.h $(SRC)globals.icc
	echo Compiling ELCH 6D Quaternion ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)elch6Dquat.o $(SRC)elch6Dquat.cc 

$(OBJ)elch6DunitQuat.o: $(SRC)elch6DunitQuat.cc $(SRC)elch6DunitQuat.h $(SRC)elch6D.h $(SRC)loopSlam6D.h $(SRC)icp6D.h $(SRC)icp6Dminimizer.h $(SRC)scan.h $(SRC)graph.h $(SRC)lum6Dquat.h $(SRC)globals.icc
	echo Compiling ELCH 6D Unit Quaternion ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)elch6DunitQuat.o $(SRC)elch6DunitQuat.cc 

$(OBJ)elch6Dslerp.o: $(SRC)elch6Dslerp.cc $(SRC)elch6Dslerp.h $(SRC)elch6D.h $(SRC)loopSlam6D.h $(SRC)icp6D.h $(SRC)icp6Dminimizer.h $(SRC)scan.h $(SRC)graph.h $(SRC)lum6Dquat.h $(SRC)globals.icc
	echo Compiling ELCH 6D SLERP Quaternion ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)elch6Dslerp.o $(SRC)elch6Dslerp.cc 

$(OBJ)icp6Dapx.o: $(SRC)icp6Dapx.h $(SRC)icp6Dapx.cc $(SRC)ptpair.h $(SRC)icp6Dminimizer.h
	echo Compiling ICP 6D with Approximation ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6Dapx.o $(SRC)icp6Dapx.cc 

$(OBJ)icp6Dsvd.o: $(SRC)icp6Dsvd.h $(SRC)icp6Dsvd.cc $(SRC)ptpair.h $(SRC)icp6Dminimizer.h 
	echo Compiling ICP 6D with SVD ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6Dsvd.o $(SRC)icp6Dsvd.cc 

$(OBJ)icp6Dortho.o: $(SRC)icp6Dortho.h $(SRC)icp6Dortho.cc $(SRC)ptpair.h $(SRC)icp6Dminimizer.h 
	echo Compiling ICP 6D with Orthonormal Matrices ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6Dortho.o $(SRC)icp6Dortho.cc 

$(OBJ)icp6Dquat.o: $(SRC)icp6Dquat.h $(SRC)icp6Dquat.cc $(SRC)ptpair.h $(SRC)icp6Dminimizer.h
	echo Compiling ICP 6D with Quaternion ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6Dquat.o $(SRC)icp6Dquat.cc 

$(OBJ)icp6Dhelix.o: $(SRC)icp6Dhelix.h $(SRC)icp6Dhelix.cc $(SRC)ptpair.h $(SRC)icp6Dminimizer.h
	echo Compiling ICP 6D with Helix ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)icp6Dhelix.o $(SRC)icp6Dhelix.cc

$(OBJ)graph.o: $(SRC)graph.h $(SRC)graph.cc $(SRC)globals.icc $(SRC)scan.h
	echo Compiling Graph ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)graph.o $(SRC)graph.cc

$(OBJ)csparse.o: $(SRC)sparse/csparse.h $(SRC)sparse/csparse.cc
	echo Compiling Csparse ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)csparse.o $(SRC)sparse/csparse.cc

docu_html:
	doxygen doc/doxygen.cfg
	cd $(DOC) ; zip -q html.zip html/*
	echo
	echo

docu_latex:
	cd $(DOC)latex ; make
	cd $(DOC)latex ; dvips refman
	cd $(DOC)latex ; ps2pdf14 refman.ps refman.pdf
	cp $(DOC)latex/refman.pdf $(DOC)

docu_hl:	$(DOC)high_level_doc/documentation.tex
	cd $(DOC)high_level_doc ; latex documentation.tex
	cd $(DOC)high_level_doc ; bibtex documentation
	cd $(DOC)high_level_doc ; latex documentation.tex
	cd $(DOC)high_level_doc ; dvips documentation
	cd $(DOC)high_level_doc ; ps2pdf14 documentation.ps ../documentation_HL.pdf


############# SLAM6D LIBS ##############

$(OBJ)libANN.a: $(SRC)ann_1.1.1_modified/src/*.cpp $(SRC)ann_1.1.1_modified/src/*.h
	echo Making modified ANN lib ...
	cd $(SRC)ann_1.1.1_modified/src ; make

$(OBJ)libnewmat.a: $(SRC)newmat/*.cpp $(SRC)newmat/*.h
	echo Compiling Newmat ...
	cd $(SRC)newmat ; make

$(BIN)scan_io_uos.so: $(SRC)scan_io.h $(SRC)scan_io_uos.h $(SRC)scan_io_uos.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading UOS scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_uos.so $(SRC)scan_io_uos.cc

ifdef WITH_RIVLIB
$(BIN)scan_io_rxp.so: $(SRC)scan_io.h $(SRC)scan_io_rxp.h $(SRC)scan_io_rxp.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading RIEGL rxp scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_rxp.so $(SRC)scan_io_rxp.cc $(SRC)riegl/libscanlib-mt-s.a $(SRC)riegl/libctrllib-mt-s.a $(SRC)riegl/libboost_system-mt-s-1_35-vns.a -lpthread
else
$(BIN)scan_io_rxp.so: 
endif

$(BIN)scan_io_uos_map.so: $(SRC)scan_io.h $(SRC)scan_io_uos_map.h $(SRC)scan_io_uos_map.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading UOS scans with given map ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_uos_map.so $(SRC)scan_io_uos_map.cc 

$(BIN)scan_io_uos_frames.so: $(SRC)scan_io.h $(SRC)scan_io_uos_frames.h $(SRC)scan_io_uos_frames.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading UOS scans with frames as poses...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_uos_frames.so $(SRC)scan_io_uos_frames.cc

$(BIN)scan_io_uos_map_frames.so: $(SRC)scan_io.h $(SRC)scan_io_uos_map_frames.h $(SRC)scan_io_uos_map_frames.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading UOS scans with given map and frames as poses...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_uos_map_frames.so $(SRC)scan_io_uos_map_frames.cc

$(BIN)scan_io_old.so: $(SRC)scan_io.h $(SRC)scan_io_old.h $(SRC)scan_io_old.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading old UOS scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_old.so $(SRC)scan_io_old.cc 

$(BIN)scan_io_x3d.so: $(SRC)scan_io.h $(SRC)scan_io_x3d.h $(SRC)scan_io_x3d.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading x3d scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_x3d.so $(SRC)scan_io_x3d.cc 

$(BIN)scan_io_rts.so: $(SRC)scan_io.h $(SRC)scan_io_rts.h $(SRC)scan_io_rts.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading RTS scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_rts.so $(SRC)scan_io_rts.cc 

$(BIN)scan_io_iais.so: $(SRC)scan_io.h $(SRC)scan_io_iais.h $(SRC)scan_io_iais.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading IAIS scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_iais.so $(SRC)scan_io_iais.cc 

$(BIN)scan_io_rts_map.so: $(SRC)scan_io.h $(SRC)scan_io_rts_map.h $(SRC)scan_io_rts_map.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading RTS scans with given map ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_rts_map.so $(SRC)scan_io_rts_map.cc 

$(BIN)scan_io_riegl_bin.so: $(SRC)scan_io.h $(SRC)scan_io_riegl_bin.h $(SRC)scan_io_riegl_bin.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading Riegl scans in binary mode ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_riegl_bin.so $(SRC)scan_io_riegl_bin.cc 

$(BIN)scan_io_riegl_txt.so: $(SRC)scan_io.h $(SRC)scan_io_riegl_txt.h $(SRC)scan_io_riegl_txt.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading Riegl scans in text mode ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_riegl_txt.so $(SRC)scan_io_riegl_txt.cc 

$(BIN)scan_io_zuf.so: $(SRC)scan_io.h $(SRC)scan_io_zuf.h $(SRC)scan_io_zuf.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading Z+F scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_zuf.so $(SRC)scan_io_zuf.cc 

$(BIN)scan_io_asc.so: $(SRC)scan_io.h $(SRC)scan_io_asc.h $(SRC)scan_io_asc.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading ASC scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_asc.so $(SRC)scan_io_asc.cc 

$(BIN)scan_io_ifp.so: $(SRC)scan_io.h $(SRC)scan_io_ifp.h $(SRC)scan_io_ifp.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading IFP scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_ifp.so $(SRC)scan_io_ifp.cc 

$(BIN)scan_io_ply.so: $(SRC)scan_io.h $(SRC)scan_io_ply.h $(SRC)scan_io_ply.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading PLY scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_ply.so $(SRC)scan_io_ply.cc 

$(BIN)scan_io_xyz.so: $(SRC)scan_io.h $(SRC)scan_io_xyz.h $(SRC)scan_io_xyz.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading XYZ scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_xyz.so $(SRC)scan_io_xyz.cc 

$(BIN)scan_io_wrl.so: $(SRC)scan_io.h $(SRC)scan_io_wrl.h $(SRC)scan_io_wrl.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading VRML v1.0 scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_wrl.so $(SRC)scan_io_wrl.cc 

$(BIN)scan_io_front.so: $(SRC)scan_io.h $(SRC)scan_io_front.h $(SRC)scan_io_front.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading 2D Front scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_front.so $(SRC)scan_io_front.cc 

$(BIN)scan_io_zahn.so: $(SRC)scan_io.h $(SRC)scan_io_zahn.h $(SRC)scan_io_zahn.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc
	echo Compiling shared library for reading Zaehne scans ...
	$(GPP) $(CFLAGS) $(SHAREDFLAGS) -o $(BIN)scan_io_zahn.so $(SRC)scan_io_zahn.cc 
	echo DONE
	echo


############# SCAN REDUCTION ##############

$(BIN)scan_red: $(OBJ)scanlib.a $(SRC)globals.icc $(SRC)scan_red.cc 
	echo Compiling and Linking Scan Reduction ...
	$(GPP) $(CFLAGS) -o $(BIN)scan_red $(SRC)scan_red.cc $(OBJ)scanlib.a -ldl 
	echo DONE
	echo

############# SHOW ##############

$(BIN)show: $(OBJ)libglui.a $(SHOWSRC)show.cc $(SHOWSRC)show.h $(SHOWSRC)show.icc $(SHOWSRC)show1.icc $(SHOWSRC)show_menu.cc $(SHOWSRC)show_gl.cc $(SRC)point.h $(SRC)point.icc $(SRC)globals.icc $(OBJ)scan.o $(OBJ)vertexarray.o $(OBJ)camera.o $(OBJ)PathGraph.o $(OBJ)NurbsPath.o $(OBJ)scanlib.a
	echo Compiling and Linking Show ...
	$(GPP) $(CFLAGS) -o $(BIN)show -I$(SRC) $(SHOWSRC)show.cc $(OBJ)scanlib.a $(OBJ)vertexarray.o $(OBJ)camera.o $(OBJ)PathGraph.o $(OBJ)NurbsPath.o $(OBJ)libglui.a $(LIBRARIES)
	echo DONE
	echo

$(OBJ)vertexarray.o: $(SHOWSRC)vertexarray.h $(SHOWSRC)vertexarray.cc
	echo Compiling VertexArray ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)vertexarray.o $(SHOWSRC)vertexarray.cc

$(OBJ)camera.o: $(SHOWSRC)camera.h $(SHOWSRC)camera.cc $(SRC)globals.icc
	echo Compiling Camera ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)camera.o $(SHOWSRC)camera.cc

$(OBJ)NurbsPath.o: $(SHOWSRC)NurbsPath.h $(SHOWSRC)NurbsPath.cc $(SRC)globals.icc $(SHOWSRC)PathGraph.h
	echo Compiling NurbsPath ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)NurbsPath.o $(SHOWSRC)NurbsPath.cc

$(OBJ)PathGraph.o: $(SHOWSRC)PathGraph.h $(SHOWSRC)PathGraph.cc $(SRC)globals.icc
	echo Compiling PathGraph ...
	$(GPP) $(CFLAGS) -c -o $(OBJ)PathGraph.o $(SHOWSRC)PathGraph.cc

$(OBJ)libglui.a: $(SHOWSRC)glui/*.c $(SHOWSRC)glui/*.cpp $(SHOWSRC)glui/*.h
	echo Compiling Glui ...
	cd $(SHOWSRC)glui ; make


############# GRIDDER ##############

$(OBJ)gridder.o: $(GRIDSRC)2DGridder.cc $(GRIDSRC)scanmanager.h $(GRIDSRC)scanGrid.h $(GRIDSRC)scanToGrid.h $(GRIDSRC)parcelmanager.h $(GRIDSRC)gridlines.h
	echo Compiling 2Dgridder ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)2DGridder.cc -o $(OBJ)gridder.o

$(OBJ)grid.o: $(GRIDSRC)grid.cc $(GRIDSRC)grid.h $(GRIDSRC)gridPoint.h
	echo Compiling Grid ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)grid.cc -o $(OBJ)grid.o

$(OBJ)scanGrid.o: $(GRIDSRC)scanGrid.cc $(GRIDSRC)scanGrid.h $(GRIDSRC)grid.h
	echo Compiling ScanGrid ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)scanGrid.cc -o $(OBJ)scanGrid.o

$(OBJ)scanToGrid.o: $(GRIDSRC)scanToGrid.cc $(GRIDSRC)scanToGrid.h
	echo Compiling ScanToGrid ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)scanToGrid.cc -o $(OBJ)scanToGrid.o

$(OBJ)gridPoint.o: $(GRIDSRC)gridPoint.cc $(GRIDSRC)gridPoint.h
	echo Compiling GridPoint ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)gridPoint.cc -o $(OBJ)gridPoint.o

$(OBJ)scanmanager.o: $(GRIDSRC)scanmanager.cc $(GRIDSRC)scanmanager.h
	echo Compiling Scanmanager ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)scanmanager.cc -o $(OBJ)scanmanager.o

$(OBJ)parcel.o: $(GRIDSRC)parcel.cc $(GRIDSRC)parcel.h $(OBJ)grid.o
	echo Compiling Parcel ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)parcel.cc -o $(OBJ)parcel.o

$(OBJ)parcelmanager.o: $(GRIDSRC)parcelmanager.cc $(GRIDSRC)parcelmanager.h
	echo Compiling Parcelmanager ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)parcelmanager.cc -o $(OBJ)parcelmanager.o

$(OBJ)parcelinfo.o: $(GRIDSRC)parcelinfo.cc $(GRIDSRC)parcelinfo.h
	echo Compiling Parcelinfo ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)parcelinfo.cc -o $(OBJ)parcelinfo.o

$(OBJ)gridWriter.o: $(GRIDSRC)gridWriter.h $(GRIDSRC)gridWriter.cc
	echo Compiling GridWriter ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)gridWriter.cc -o $(OBJ)gridWriter.o

$(OBJ)viewpointinfo.o: $(GRIDSRC)viewpointinfo.h $(GRIDSRC)viewpointinfo.cc $(GRIDSRC)scanGrid.h
	echo Compiling Viewpointinfo ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)viewpointinfo.cc -o $(OBJ)viewpointinfo.o

$(OBJ)line.o: $(GRIDSRC)line.cc $(GRIDSRC)line.h $(GRIDSRC)gridPoint.h
	echo Compiling Line ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)line.cc -o $(OBJ)line.o

$(OBJ)gridlines.o: $(GRIDSRC)gridlines.cc $(GRIDSRC)gridlines.h $(GRIDSRC)hough.h $(GRIDSRC)line.h $(GRIDSRC)grid.h
	echo Compiling Gridlines ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)gridlines.cc -o $(OBJ)gridlines.o

$(OBJ)hough.o: $(GRIDSRC)hough.cc $(GRIDSRC)hough.h
	echo Compiling Hough ...
	$(GPP) $(CFLAGS) -c $(GRIDSRC)hough.cc -o $(OBJ)hough.o

$(BIN)2DGridder: $(OBJ)gridder.o $(OBJ)line.o $(OBJ)gridlines.o $(OBJ)hough.o $(OBJ)viewpointinfo.o $(OBJ)gridWriter.o $(OBJ)parcelmanager.o $(OBJ)parcel.o $(OBJ)parcelinfo.o $(OBJ)scanGrid.o $(OBJ)grid.o $(OBJ)scanToGrid.o $(OBJ)gridPoint.o $(OBJ)scan.o $(OBJ)scanmanager.o $(OBJ)kd.o $(OBJ)kdc.o
	echo Compiling and Linking Grid ...
	$(GPP) $(CFLAGS) -o $(BIN)2DGridder $(OBJ)viewpointinfo.o $(OBJ)line.o $(OBJ)gridlines.o $(OBJ)hough.o $(OBJ)gridder.o $(OBJ)gridWriter.o $(OBJ)parcelmanager.o $(OBJ)parcelinfo.o $(OBJ)scanmanager.o $(OBJ)grid.o $(OBJ)scanGrid.o $(OBJ)parcel.o $(OBJ)gridPoint.o $(OBJ)scanToGrid.o $(OBJ)scan.o $(OBJ)octtree.o $(OBJ)kd.o $(OBJ)kdc.o -ldl  -lstdc++
	echo DONE
	echo


############# TOOLS ##############

$(BIN)frame_to_graph: $(SRC)frame_to_graph.cc $(SRC)globals.icc
	echo Compiling and linking Frame_to_graph ...
	$(GPP) $(CFLAGS) -o $(BIN)frame_to_graph $(SRC)frame_to_graph.cc 
	echo DONE
	echo

$(BIN)convergence: $(SRC)convergence.cc $(SRC)convergence.h $(SRC)globals.icc
	echo Compiling and linking Convergence ...
	$(GPP) $(CFLAGS) -o $(BIN)convergence $(SRC)convergence.cc
	echo DONE
	echo

$(BIN)graph_balancer: $(OBJ)elch6D.o $(SRC)graph_balancer.cc $(SRC)graph.h
	echo Compiling and linking Graph Balancer ...
	$(GPP) $(CFLAGS) -lboost_graph-mt -o $(BIN)graph_balancer $(SRC)graph_balancer.cc $(OBJ)elch6D.o 
	echo DONE
	echo


############# PMD camera ##############

$(OBJ)libpmdaccess2.a: $(PMDSRC)/pmdaccess2/pmdaccess.cc
	echo Compiling libpmdaccess ...
	$(GPP) -c $(PMDSRC)/pmdaccess2/pmdaccess.cc -o $(OBJ)pmdaccess.o                                   
	ar rs $(OBJ)libpmdaccess2.a $(OBJ)pmdaccess.o  

$(OBJ)cvpmd.o: $(PMDSRC)cvpmd.cc
	echo Compiling OpenCV PMD ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC)pmdaccess2 -I$(SRC) -c -o $(OBJ)cvpmd.o $(PMDSRC)cvpmd.cc

$(OBJ)pmdWrap.o: $(PMDSRC)pmdWrap.cc
	echo Compiling PMD wrapper ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC)pmdaccess2 -I$(SRC) -c -o $(OBJ)pmdWrap.o $(PMDSRC)pmdWrap.cc

$(BIN)grabVideoAnd3D: $(OBJ)pmdWrap.o $(OBJ)cvpmd.o $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(OBJ)libnewmat.a $(OBJ)libpmdaccess2.a $(PMDSRC)offline/grabVideoAnd3D.cc
	echo Compiling and Linking video and pmd grabber ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(PMDLIBS) $(OBJ)pmdWrap.o $(OBJ)cvpmd.o $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(OBJ)libnewmat.a $(OBJ)libpmdaccess2.a -o $(BIN)grabVideoAnd3D $(PMDSRC)offline/grabVideoAnd3D.cc

$(BIN)convertToSLAM6D: $(OBJ)pmdWrap.o $(OBJ)cvpmd.o $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(OBJ)libnewmat.a $(OBJ)libpmdaccess2.a $(PMDSRC)offline/convertToSLAM6D.cc
	echo Compiling and Linking converting tool to slam6D ...
	echo Linking converting tool to slam6D ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(PMDLIBS) $(OBJ)pmdWrap.o $(OBJ)cvpmd.o $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(OBJ)libnewmat.a $(OBJ)libpmdaccess2.a -o $(BIN)convertToSLAM6D $(PMDSRC)offline/convertToSLAM6D.cc

$(BIN)calibrate: $(PMDSRC)/calibrate/calibrate.cc
	echo Compiling and Linking calibrate ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(PMDLIBS) -o $(BIN)calibrate $(PMDSRC)/calibrate/calibrate.cc

$(BIN)grabFramesCam: $(PMDSRC)calibrate/grabFramesCam.cc
	echo Compiling and Linking grab frames camera ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(PMDLIBS) -o $(BIN)grabFramesCam $(PMDSRC)calibrate/grabFramesCam.cc

$(BIN)grabFramesPMD: $(PMDSRC)calibrate/grabFramesPMD.cc $(OBJ)libpmdaccess2.a
	echo Compiling and Linking grab frames PMD ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(OBJ)cvpmd.o $(OBJ)pmdWrap.o $(OBJ)libpmdaccess2.a $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(PMDLIBS) $(OBJ)libnewmat.a -o $(BIN)grabFramesPMD $(PMDSRC)calibrate/grabFramesPMD.cc

$(BIN)extrinsic: $(PMDSRC)calibrate/extrinsic.cc
	echo Compiling and Linking extrinsic camera calibration ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(PMDLIBS) -o $(BIN)extrinsic $(PMDSRC)calibrate/extrinsic.cc

$(BIN)pose: $(PMDSRC)pose/pose.cc $(PMDSRC)pose/history.cc $(OBJ)libpmdaccess2.a
	echo Compiling and Linking PMD pose ...
	$(GPP) $(CFLAGS) $(PMDPKG) -I$(PMDSRC) -I$(PMDSRC)pmdaccess2 -I$(SRC) $(OBJ)cvpmd.o $(OBJ)pmdWrap.o $(OBJ)libpmdaccess2.a $(OBJ)icp6D.o $(OBJ)icp6Dapx.o $(OBJ)icp6Dhelix.o $(OBJ)icp6Dortho.o $(OBJ)icp6Dquat.o $(OBJ)icp6Dsvd.o $(OBJ)scanlib.a $(PMDLIBS) $(OBJ)libnewmat.a -o $(BIN)pose $(PMDSRC)pose/pose.cc $(PMDSRC)pose/history.cc
	echo DONE
	echo

############# SIFT based registration ##############

$(OBJ)LoweDetector.o: $(APSSRC)LoweDetector.c
	echo Compiling LoweDetector ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)LoweDetector.o -c $(APSSRC)LoweDetector.c

$(OBJ)RANSAC.o: $(APSSRC)RANSAC.c
	echo Compiling RANSAC ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)RANSAC.o -c $(APSSRC)RANSAC.c

$(OBJ)GaussianConvolution.o: $(APSSRC)GaussianConvolution.c
	echo Compiling GaussianConvolution ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)GaussianConvolution.o -c $(APSSRC)GaussianConvolution.c

$(OBJ)ScaleSpace.o: $(APSSRC)ScaleSpace.c
	echo Compiling ScaleSpace ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)ScaleSpace.o -c $(APSSRC)ScaleSpace.c

$(OBJ)KeypointXML.o: $(APSSRC)KeypointXML.c
	echo Compiling KeypointXML ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)KeypointXML.o -c $(APSSRC)KeypointXML.c

$(OBJ)MatchKeys.o: $(APSSRC)MatchKeys.c
	echo Compiling MatchKeys ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)MatchKeys.o -c $(APSSRC)MatchKeys.c

$(OBJ)KDTree.o: $(APSSRC)KDTree.c
	echo Compiling KDTree for SIFT ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)KDTree.o -c $(APSSRC)KDTree.c

$(OBJ)BondBall.o: $(APSSRC)BondBall.c
	echo Compiling BondBall ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)BondBall.o -c $(APSSRC)BondBall.c

$(OBJ)AreaFilter.o: $(APSSRC)AreaFilter.c
	echo Compiling AreaFilter ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)AreaFilter.o -c $(APSSRC)AreaFilter.c

$(OBJ)ImageMatchModel.o: $(APSSRC)ImageMatchModel.c
	echo Compiling ImageMatchModel ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)ImageMatchModel.o -c $(APSSRC)ImageMatchModel.c

$(OBJ)Transform.o: $(APSSRC)Transform.c
	echo Compiling Transform ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)Transform.o -c $(APSSRC)Transform.c

$(OBJ)DisplayImage.o: $(APSSRC)DisplayImage.c
	echo Compiling DisplayImager ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)DisplayImage.o -c $(APSSRC)DisplayImage.c

$(OBJ)ImageMap.o: $(APSSRC)ImageMap.c
	echo Compiling ImageMap ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)ImageMap.o -c $(APSSRC)ImageMap.c

$(OBJ)HashTable.o: $(APSSRC)HashTable.c
	echo Compiling HashTable ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)HashTable.o -c $(APSSRC)HashTable.c

$(OBJ)ArrayList.o: $(APSSRC)ArrayList.c
	echo Compiling ArrayList ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)ArrayList.o -c $(APSSRC)ArrayList.c

$(OBJ)SAreaFilter.o: $(APSSRC)SAreaFilter.c
	echo Compiling HashTable ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)SAreaFilter.o -c $(APSSRC)ASAreaFilter.c

$(OBJ)Random.o: $(APSSRC)Random.c
	echo Compiling Random ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)Random.o -c $(APSSRC)Random.c

$(OBJ)SimpleMatrix.o: $(APSSRC)SimpleMatrix.c
	echo Compiling SimpleMatrix ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)SimpleMatrix.o -c $(APSSRC)SimpleMatrix.c

$(OBJ)Utils.o: $(APSSRC)Utils.c
	echo Compiling Utils ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)Utils.o -c $(APSSRC)Utils.c

$(OBJ)liblibsift.a: $(OBJ)LoweDetector.o $(OBJ)RANSAC.o $(OBJ)GaussianConvolution.o $(OBJ)ScaleSpace.o $(OBJ)KeypointXML.o $(OBJ)MatchKeys.o $(OBJ)KDTree.o $(OBJ)BondBall.o $(OBJ)AreaFilter.o $(OBJ)ImageMatchModel.o $(OBJ)Transform.o $(OBJ)DisplayImage.o $(OBJ)ImageMap.o $(OBJ)HashTable.o $(OBJ)ArrayList.o $(OBJ)Random.o $(OBJ)SimpleMatrix.o $(OBJ)Utils.o
	echo Linking LibLibSift ...
	ar cr $(OBJ)liblibsift.a $(OBJ)LoweDetector.o $(OBJ)RANSAC.o $(OBJ)GaussianConvolution.o $(OBJ)ScaleSpace.o $(OBJ)KeypointXML.o $(OBJ)MatchKeys.o $(OBJ)KDTree.o $(OBJ)BondBall.o $(OBJ)AreaFilter.o $(OBJ)ImageMatchModel.o $(OBJ)Transform.o $(OBJ)DisplayImage.o $(OBJ)ImageMap.o $(OBJ)HashTable.o $(OBJ)ArrayList.o $(OBJ)Random.o $(OBJ)SimpleMatrix.o $(OBJ)Utils.o
	ranlib $(OBJ)liblibsift.a

$(OBJ)AutoPano.o: $(APSSRC)AutoPano.c
	echo Compiling AutoPano ...
	$(GCC) $(CFLAGS) -DHAS_PANO13 -O2 -I$(APSSRC) -o $(OBJ)AutoPano.o -c $(APSSRC)AutoPano.c

$(BIN)autopano: $(OBJ)AutoPano.o $(OBJ)liblibsift.a
	echo Linking AutoPano ...
	$(GCC) $(CFLAGS) -o $(BIN)autopano $(OBJ)AutoPano.o -rdynamic $(OBJ)liblibsift.a -ljpeg -ltiff -lpng -lz -lpano13 -lxml2

$(BIN)generatekeys: $(OBJ)GenerateKeys.o $(OBJ)liblibsift.a
	echo Linking GenerateKeys ...
	$(GCC) $(CFLAGS) -o $(BIN)generatekeys $(OBJ)GenerateKeys.o -rdynamic $(OBJ)liblibsift.a -ljpeg -ltiff -lpng -lz -lpano13 -lxml2

$(OBJ)ANNkd_wrap.o: $(APSSRC)APSCpp/ANNkd_wrap.cpp
	echo Compiling ANN kd wrap ...
	$(GPP) $(CFLAGS) -DHAS_PANO13 -o $(OBJ)ANNkd_wrap.o -c -I$(SRC)ann_1.1.1_modified/include/ $(APSSRC)APSCpp/ANNkd_wrap.cpp

$(OBJ)APSCpp_main.o: $(APSSRC)APSCpp/APSCpp_main.c
	echo Compiling APSCpp_main ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)APSCpp_main.o -c -I$(APSSRC) $(APSSRC)APSCpp/APSCpp_main.c

$(OBJ)APSCpp.o: $(APSSRC)APSCpp/APSCpp.c
	echo Compiling APSCpp ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)APSCpp.o -c -I$(APSSRC) $(APSSRC)APSCpp/APSCpp.c

$(OBJ)CamLens.o: $(APSSRC)APSCpp/CamLens.c 
	echo Compiling CamLens ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)CamLens.o -c -I$(APSSRC) $(APSSRC)APSCpp/CamLens.c

$(OBJ)HermiteSpline.o: $(APSSRC)APSCpp/HermiteSpline.c 
	echo Compiling HermiteSpline ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)HermiteSpline.o -c -I$(APSSRC) $(APSSRC)APSCpp/HermiteSpline.c

$(OBJ)saInterp.o: $(APSSRC)APSCpp/saInterp.c 
	echo Compiling saInterp ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)saInterp.o -c -I$(APSSRC) $(APSSRC)APSCpp/saInterp.c

$(OBJ)saRemap.o: $(APSSRC)APSCpp/saRemap.c
	echo Compiling saRemap ...
	$(GCC) $(FLAGS) -DHAS_PANO13 -o $(OBJ)saRemap.o -c -I$(APSSRC) $(APSSRC)APSCpp/saRemap.c

$(BIN)autopano-sift-c: $(OBJ)ANNkd_wrap.o $(OBJ)APSCpp_main.o $(OBJ)APSCpp.o $(OBJ)CamLens.o $(OBJ)HermiteSpline.o $(OBJ)saInterp.o $(OBJ)saRemap.o $(OBJ)libANN.a $(OBJ)liblibsift.a
	echo Linking autopano-sift-c
	$(GPP) $(CFLAGS) -DHAS_PANO13 $(OBJ)ANNkd_wrap.o $(OBJ)APSCpp_main.o $(OBJ)APSCpp.o $(OBJ)CamLens.o $(OBJ)HermiteSpline.o $(OBJ)saInterp.o $(OBJ)saRemap.o -o $(BIN)autopano-sift-c -rdynamic $(OBJ)libANN.a $(OBJ)liblibsift.a -ljpeg -ltiff -lpng -lz -lz -lpano13 -lxml2 -lstdc++ 
	echo DONE
	echo 




##################################################################################

svn_clean: # "are you sure?"-version
	@find . -name '.svn'         | xargs zip .svn.zip -r -q -m

svn_clean_del:
	@find . -name '.svn'         | xargs rm -r -f

clean:	
	/bin/rm -f $(OBJ)*
	/bin/rm -f $(BIN)*.so
	cd $(SRC)newmat ; make clean
	cd $(SHOWSRC)glui ; make clean
	cd $(DOC)high_level_doc ; make clean
#	cd $(DOC)latex ; make clean
