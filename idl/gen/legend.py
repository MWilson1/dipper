#!/usr/bin/env python

import os
import time
import numpy as np

#+ 
# NAME: 
#       AL_LEGEND 
# PURPOSE: 
#       Create an annotation legend for a plot. 
# EXPLANATION: 
# 
#       This procedure makes a legend for a plot.  The legend can contain 
#       a mixture of symbols, linestyles, Hershey characters (vectorfont), 
#       and filled polygons (usersym).  A test procedure, al_legendtest.pro, 
#       shows legend's capabilities.  Placement of the legend is controlled 
#       with keywords like /right, /top, and /center or by using a position 
#       keyword for exact placement (position=[x,y]) or via mouse (/position). 
# 
#       The procedure CGLEGEND in the Coyote library provides a similar 
#       capability.     https://www.idlcoyote.com/idldoc/cg/cglegend.html 
# CALLING SEQUENCE: 
#       AL_LEGEND [,items][,keyword options] 
# EXAMPLES: 
#       The call: 
#               al_legend,['Plus sign','Asterisk','Period'],psym=[1,2,3] 
#         produces: 
#               ----------------- 
#               |               | 
#               |  + Plus sign  | 
#               |  * Asterisk   | 
#               |  . Period     | 
#               |               | 
#               ----------------- 
#         Each symbol is drawn with a cgPlots command, so they look OK. 
#         Other examples are given in optional output keywords. 
# 
#       lines = indgen(6)                       ; for line styles 
#       items = 'linestyle '+strtrim(lines,2)   ; annotations 
#       al_legend,items,linestyle=lines         ; vertical legend---upper left 
#       items = ['Plus sign','Asterisk','Period'] 
#       sym = [1,2,3] 
#       al_legend,items,psym=sym                   ; ditto except using symbols 
#       al_legend,items,psym=sym,/horizontal       ; horizontal format 
#       al_legend,items,psym=sym,box=0             ; sans border 
#       al_legend,items,psym=sym,delimiter='='     ; embed '=' betw psym & text 
#       al_legend,items,psym=sym,margin=2          ; 2-character margin 
#       al_legend,items,psym=sym,position=[x,y]    ; upper left in data coords 
#       al_legend,items,psym=sym,pos=[x,y],/norm   ; upper left in normal coords 
#       al_legend,items,psym=sym,pos=[x,y],/device ; upper left in device coords 
#       al_legend,items,psym=sym,/position         ; interactive position 
#       al_legend,items,psym=sym,/right            ; at upper right 
#       al_legend,items,psym=sym,/bottom           ; at lower left 
#       al_legenditems,psym=sym,/center           ; approximately near center 
#       al_legend,items,psym=sym,number=2          ; plot two symbols, not one 
#     Plot 3 filled colored squares 
#       al_legend,items,/fill,psym=[8,8,8],colors=['red','green','blue'] 
# 
#        Another example of the use of AL_LEGEND can be found at 
#        http://www.idlcoyote.com/cg_tips/al_legend.php 
# INPUTS: 
#       items = text for the items in the legend, a string array. 
#               For example, items = ['diamond','asterisk','square']. 
#               You can omit items if you don't want any text labels.  The 
#               text can include many LaTeX symbols (e.g. $\leq$) for a less 
#               than equals symbol) as described in cgsymbol.pro. 
# OPTIONAL INPUT KEYWORDS: 
# 
#       linestyle = array of linestyle numbers  If linestyle[i] < 0, then omit 
#               ith symbol or line to allow a multi-line entry.     If 
#               linestyle = -99 then text will be left-justified. 
#       psym = array of plot symbol numbers or names.  If psym[i] is negative, 
#               then a line connects pts for ith item.  If psym[i] = 8, then the 
#               procedure USERSYM is called with vertices defined in the 
#               keyword usersym.   If psym[i] = 88, then use the previously 
#               defined user symbol.    If 11 <= psym[i] <= 46 then David 
#               Fanning's function CGSYMCAT() will be used for additional 
#               symbols.   Note that PSYM=10 (histogram plot mode) is not 
#               allowed since it cannot be used with the cgPlots command. 
#       vectorfont = vector-drawn characters for the sym/line column, e.g., 
#               ['!9B!3','!9C!3','!9D!3'] produces an open square, a checkmark, 
#               and a partial derivative, which might have accompanying items 
#               ['BOX','CHECK','PARTIAL DERIVATIVE']. 
#               There is no check that !p.font is set properly, e.g., -1 for 
#               X and 0 for PostScript.  This can produce an error, e.g., use 
#               !20 with PostScript and !p.font=0, but allows use of Hershey 
#               *AND* PostScript fonts together. 
#       N. B.: Choose any of linestyle, psym, and/or vectorfont.  If none is 
#               present, only the text is output.  If more than one 
#               is present, all need the same number of elements, and normal 
#               plot behaviour occurs. 
#               By default, if psym is positive, you get one point so there is 
#               no connecting line.  If vectorfont[i] = '', 
#               then cgPlots is called to make a symbol or a line, but if 
#               vectorfont[i] is a non-null string, then cgText is called. 
#       /help = flag to print header 
#       /horizontal = flag to make the legend horizontal 
#       /vertical = flag to make the legend vertical (D=vertical) 
#       background_color - color name or number to fill the legend box. 
#              Automatically sets /clear.    (D = -1) 
#       box = flag to include/omit box around the legend (D=include) 
#		  outline_color = color of box outline (D = !P.color) 
#       bthick = thickness of the legend box (D = !P.thick) 
#       charsize = just like !p.charsize for plot labels 
#       charthick = just like !p.charthick for plot labels 
#       clear = flag to clear the box area before drawing the legend 
#       colors = array of colors names or numbers for plot symbols/lines 
#          See cgCOLOR for list of color names.   Default is 'Opposite' 
#          If you are using index colors (0-255), then supply color as a byte, 
#          integer or string, but not as a long, which will be interpreted as 
#          a decomposed color. See http://www.idlcoyote.com/cg_tips/legcolor.php 
#       delimiter = embedded character(s) between symbol and text (D=none) 
#       font = scalar font graphics keyword (-1,0 or 1) for text 
#       linsize = Scale factor for line length (0-1), default = 1 
#                 Set to 0 to give a dot, 0.5 give half default line length 
#       margin = margin around text measured in characters and lines 
#       number = number of plot symbols to plot or length of line (D=1) 
#       spacing = line spacing (D=bit more than character height) 
#       position = data coordinates of the /top (D) /left (D) of the legend 
#       pspacing = psym spacing (D=3 characters) (when number of symbols is 
#             greater than 1) 
#       textcolors = array of color names or numbers for text.  See cgCOLOR 
#          for a list of color names.   Default is 'Opposite' of background 
#       thick = array of line thickness numbers (D = !P.thick), if used, then 
#               linestyle must also be specified 
#       normal = use normal coordinates for position, not data 
#       device = use device coordinates for position, not data 
#       /window - if set then send legend to a resizeable graphics window 
#       usersym = 2-D array of vertices, cf. usersym in IDL manual. 
#             (/USERSYM =square, default is to use existing USERSYM definition) 
#       /fill = flag to fill the usersym 
#       /left_legend = flag to place legend snug against left side of plot 
#                 window (D) 
#       /right_legend = flag to place legend snug against right side of plot 
#               window.    If /right,pos=[x,y], then x is position of RHS and 
#               text runs right-to-left. 
#       /top_legend = flag to place legend snug against top of plot window (D) 
#       /bottom = flag to place legend snug against bottom of plot window 
#               /top,pos=[x,y] and /bottom,pos=[x,y] produce same positions. 
# 
#       If LINESTYLE, PSYM, VECTORFONT, SYMSIZE, THICK, COLORS, or 
#       TEXTCOLORS are supplied as scalars, then the scalar value is set for 
#       every line or symbol in the legend. 
# Outputs: 
#       legend to current plot device 
# OPTIONAL OUTPUT KEYWORDS: 
#       corners = 4-element array, like !p.position, of the normalized 
#         coords for the box (even if box=0): [llx,lly,urx,ury]. 
#         Useful for multi-column or multi-line legends, for example, 
#         to make a 2-column legend, you might do the following: 
#           c1_items = ['diamond','asterisk','square'] 
#           c1_psym = [4,2,6] 
#           c2_items = ['solid','dashed','dotted'] 
#           c2_line = [0,2,1] 
#           al_legend,c1_items,psym=c1_psym,corners=c1,box=0 
#           al_legend,c2_items,line=c2_line,corners=c2,box=0,pos=[c1[2],c1[3]] 
#           c = [c1[0]<c2[0],c1[1]<c2[1],c1[2]>c2[2],c1[3]>c2[3]] 
#         cgplots,[c[0],c[0],c[2],c[2],c[0]],[c[1],c[3],c[3],c[1],c[1]],/norm 
# 
#         Useful also to place the legend.  Here's an automatic way to place 
#         the legend in the lower right corner.  The difficulty is that the 
#         legend's width is unknown until it is plotted.  In this example, 
#         the legend is plotted twice: the first time in the upper left, the 
#         second time in the lower right. 
# 
#         al_legend,['1','22','333','4444'],linestyle=indgen(4),corners=corners 
#                       ; BOGUS LEGEND---FIRST TIME TO REPORT CORNERS 
#           xydims = [corners[2]-corners[0],corners[3]-corners[1]] 
#                       ; SAVE WIDTH AND HEIGHT 
#           chdim=[!d.x_ch_size/float(!d.x_size),!d.y_ch_size/float(!d.y_size)] 
#                       ; DIMENSIONS OF ONE CHARACTER IN NORMALIZED COORDS 
#           pos = [!x.window[1]-chdim[0]-xydims[0] ;                       ,!y.window[0]+chdim[1]+xydims[1]] 
#                       ; CALCULATE POSITION FOR LOWER RIGHT 
#           cgplot,findgen(10)    ; SIMPLE PLOT; YOU DO WHATEVER YOU WANT HERE. 
#           al_legend,['1','22','333','4444'],linestyle=indgen(4),pos=pos 
#                       ; REDO THE LEGEND IN LOWER RIGHT CORNER 
#         You can modify the pos calculation to place the legend where you 
#         want.  For example to place it in the upper right: 
#           pos = [!x.window[1]-chdim[0]-xydims[0],!y.window[1]-xydims[1]] 
# Common blocks: 
#       none 
# Procedure: 
#       If keyword help is set, call doc_library to print header. 
#       See notes in the code.  Much of the code deals with placement of the 
#       legend.  The main problem with placement is not being 
#       able to sense the length of a string before it is output.  Some crude 
#       approximations are used for centering. 
# Restrictions: 
#       Here are some things that aren't implemented. 
#       - An orientation keyword would allow lines at angles in the legend. 
#       - An array of usersyms would be nice---simple change. 
#       - An order option to interchange symbols and text might be nice. 
#       - Somebody might like double boxes, e.g., with box = 2. 
#       - Another feature might be a continuous bar with ticks and text. 
#       - There are no guards to avoid writing outside the plot area. 
#       - There is no provision for multi-line text, e.g., '1st line!c2nd line' 
#         Sensing !c would be easy, but !c isn't implemented for PostScript. 
#         A better way might be to simply output the 2nd line as another item 
#         but without any accompanying symbol or linestyle.  A flag to omit 
#         the symbol and linestyle is linestyle[i] = -1. 
#       - There is no ability to make a title line containing any of titles 
#         for the legend, for the symbols, or for the text. 
# Notes: 
#       This procedure was originally named LEGEND, but a distinct LEGEND() 
#       function was introduced into IDL V8.0.   Therefore, the 
#       original LEGEND procedure was renamed to AL_LEGEND to avoid conflict. 
# 
# Modification history: 
#       write, 24-25 Aug 92, F K Knight (knight@ll.mit.edu) 
#       allow omission of items or omission of both psym and linestyle, add 
#         corners keyword to facilitate multi-column legends, improve place- 
#         ment of symbols and text, add guards for unequal size, 26 Aug 92, FKK 
#       add linestyle(i)=-1 to suppress a single symbol/line, 27 Aug 92, FKK 
#       add keyword vectorfont to allow characters in the sym/line column, 
#         28 Aug 92, FKK 
#       add /top, /bottom, /left, /right keywords for automatic placement at 
#         the four corners of the plot window.  The /right keyword forces 
#         right-to-left printing of menu. 18 Jun 93, FKK 
#       change default position to data coords and add normal, data, and 
#         device keywords, 17 Jan 94, FKK 
#       add /center keyword for positioning, but it is not precise because 
#         text string lengths cannot be known in advance, 17 Jan 94, FKK 
#       add interactive positioning with /position keyword, 17 Jan 94, FKK 
#       allow a legend with just text, no plotting symbols.  This helps in 
#         simply describing a plot or writing assumptions done, 4 Feb 94, FKK 
#       added thick, symsize, and clear keyword Feb 96, W. Landsman HSTX 
#               David Seed, HR Wallingford, d.seed@hrwallingford.co.uk 
#       allow scalar specification of keywords, Mar 96, W. Landsman HSTX 
#       added charthick keyword, June 96, W. Landsman HSTX 
#       Made keyword names  left,right,top,bottom,center longer, 
#                                 Aug 16, 2000, Kim Tolbert 
#       Added ability to have regular text lines in addition to plot legend 
#       lines in legend.  If linestyle is -99 that item is left-justified. 
#       Previously, only option for no sym/line was linestyle=-1, but then text 
#       was lined up after sym/line column.    10 Oct 2000, Kim Tolbert 
#       Make default value of thick = !P.thick  W. Landsman  Jan. 2001 
#       Don't overwrite existing USERSYM definition  W. Landsman Mar. 2002 
#	     Added outline_color BT 24 MAY 2004 
#       Pass font keyword to cgText commands.  M. Fitzgerald, Sep. 2005 
#       Default spacing, pspacing should be relative to charsize. M. Perrin, July 2007 
#       Don't modify position keyword  A. Kimball/ W. Landsman Jul 2007 
#       Small update to Jul 2007 for /NORMAL coords.  W. Landsman Aug 2007 
#       Use SYMCAT() plotting symbols for 11<=PSYM<=46   W. Landsman  Nov 2009 
#       Make a sharper box edge T. Robishaw/W.Landsman July 2010 
#       Added BTHICK keyword W. Landsman October 2010 
#       Added BACKGROUND_COLOR keyword  W. Landsman February 2011 
#       Incorporate Coyote graphics  W. Landsman  February 2011 
#       Added LINSIZE keyword W.L./V.Gonzalez   May 2011 
#       Fixed a small problem with Convert_Coord when the Window keyword is set. 
#                         David Fanning, May 2011. 
#       Fixed problem when /clear and /Window are set J. Bailin/WL   May 2011 
#       CGQUERY was called instead of CGCONTROL   W.L.  June 2011 
#       Fixed typo preventing BTHICK keyword from working W.L. Dec 2011 
#       Remove call to SYMCAT() W.L. Dec 2011 
#       Changed the way the WINDOW keyword adds commands to cgWindow, and 
#       now default to BACKGROUND for background color. 1 Feb 2012 David Fanning 
#       Allow 1 element SYMSIZE for vector input, WL Apr 2012. 
#       Allow to specify symbols by cgSYMCAT() name WL Aug 2012 
#       Fixed bug when linsize, /right called simultaneously, Dec 2012, K.Stewart 
#       Added a check for embedded symbols in the items string array. March 2013. David Fanning 
# 
#- 
def legend, items, BOTTOM_LEGEND=bottom, BOX = box, CENTER_LEGEND=center,     CHARTHICK=charthick, CHARSIZE = charsize, CLEAR = clear, COLORS = colorsi,     CORNERS = corners, DATA=data, DELIMITER=delimiter, DEVICE=device,     FILL=fill, HELP = help, HORIZONTAL=horizontal,LEFT_LEGEND=left,     LINESTYLE=linestylei, MARGIN=margin, NORMAL=normal, NUMBER=number,     POSITION=position,PSPACING=pspacing, PSYM=psymi, RIGHT_LEGEND=right,     SPACING=spacing, SYMSIZE=symsizei, TEXTCOLORS=textcolorsi, THICK=thicki,     TOP_LEGEND=top, USERSYM=usersym,  VECTORFONT=vectorfonti,     VERTICAL=vertical,OUTLINE_COLOR = outline_color, FONT = font,     BTHICK=bthick, background_color = bgcolor, WINDOW=window,LINSIZE = linsize 
    # 
    #       =====>> HELP 
    # 
    compile_opt idl2 
    #On_error,2 
    if keyword_set(help) : 
        begin &:c_library,'al_legend' & return &  
    # Should this commnad be added to a resizeable graphics window? 
    IF (Keyword_Set(window)) && ((!D.Flags AND 256) != 0): 
         
        cgWindow, 'al_legend', items, BOTTOM_LEGEND=bottom, BOX = box, CENTER_LEGEND=center,             CHARTHICK=charthick, CHARSIZE = charsize, CLEAR = clear, COLORS = colorsi,             CORNERS = corners, DATA=data, DELIMITER=delimiter, DEVICE=device,             FILL=fill, HELP = help, HORIZONTAL=horizontal,LEFT_LEGEND=left,             LINESTYLE=linestylei, MARGIN=margin, NORMAL=normal, NUMBER=number,             POSITION=position,PSPACING=pspacing, PSYM=psymi, RIGHT_LEGEND=right,             SPACING=spacing, SYMSIZE=symsizei, TEXTCOLORS=textcolorsi, THICK=thicki,             TOP_LEGEND=top, USERSYM=usersym,  VECTORFONT=vectorfonti,             VERTICAL=vertical,OUTLINE_COLOR = outline_color, FONT = font,             BTHICK=thick, background_color = bgcolor, LINSIZE = linsize, ADDCMD=1 
         
        RETURN 
    # 
     
    # 
    #       =====>> SET DEFAULTS FOR SYMBOLS, LINESTYLES, AND ITEMS. 
    # 
    ni = len(items) 
    np = len(psymi) 
    nl = len(linestylei) 
    nth = len(thicki) 
    nsym = len(symsizei) 
    nv = len(vectorfonti) 
    nlpv = max([np,nl,nv]) 
    n = max([ni,np,nl,nv])# NUMBER OF ENTRIES 
    strn = str(n,2)# FOR ERROR MESSAGES 
    if n == 0 : 
        message,'No inputs!  For help, type al_legend,/help.' 
    if ni == 0: 
        items = replicate('',n)# DEFAULT BLANK ARRAY 
    else: 
        if size(items,/TNAME) != 'STRING' : 
            message,       'First parameter must be a string array.  For help, type al_legend,/help.' 
        if ni != n : 
            message,'Must have number of items equal to '+strn 
     
    items = cgCheckForSymbols(items)# Check for embedded symbols in the items array. 
    symline = (np != 0) || (nl != 0)# FLAG TO PLOT SYM/LINE 
    if (np != 0) && (np != n) && (np != 1) : 
        message,         'Must have 0, 1 or '+strn+' elements in PSYM array.' 
    if (nl != 0) && (nl != n) && (nl != 1) : 
        message,          'Must have 0, 1 or '+strn+' elements in LINESTYLE array.' 
    if (nth != 0) && (nth != n) && (nth != 1) : 
        message,          'Must have 0, 1 or '+strn+' elements in THICK array.' 
     
    case nl of 
        0: linestyle = intarr(n)#Default = solid 
        1: linestyle = intarr(n)  + linestylei 
        else: linestyle = linestylei 
 
     
    case nsym of 
        0: symsize = replicate(!p.symsize,n)#Default = !P.SYMSIZE 
        1: symsize = intarr(n) + symsizei 
        else: symsize = symsizei 
 
     
     
    case nth of 
        0: thick = replicate(!p.thick,n)#Default = !P.THICK 
        1: thick = intarr(n) + thicki 
        else: thick = thicki 
 
     
    if size(psymi,/TNAME) == 'STRING': 
        psym = intarr(n) 
        for i in range(len(psymi)): 
            psym[i] = cgsymcat(psymi[i]) 
    else: 
         
        case np of#Get symbols 
            0: psym = intarr(n)#Default = solid 
            1: psym = intarr(n) + psymi 
            else: psym = psymi 
 
     
    case nv of 
        0: vectorfont = replicate('',n) 
        1: vectorfont = replicate(vectorfonti,n) 
        else: vectorfont = vectorfonti 
 
    # 
    #       =====>> CHOOSE VERTICAL OR HORIZONTAL ORIENTATION. 
    # 
    if len(horizontal) == 0 :# D=VERTICAL 
        $ 
    setdefaultvalue, vertical, 1 else   setdefaultvalue, vertical, ~horizontal 
         
        # 
        #       =====>> SET DEFAULTS FOR OTHER OPTIONS. 
        # 
        setdefaultvalue, box, 1 
        if len(bgcolor) != 0 : 
            clear = 1 
        setdefaultvalue, bgcolor, 'BACKGROUND' 
        setdefaultvalue, clear, 0 
        setdefaultvalue, linsize, 1. 
        setdefaultvalue, margin, 0.5 
        setdefaultvalue, delimiter, '' 
        setdefaultvalue, charsize, !p.charsize 
        setdefaultvalue, charthick, !p.charthick 
        if charsize == 0 : 
            charsize = 1 
        setdefaultvalue, number, 1 
        # Default color is opposite the background color 
        case len(colorsi) of 
            0: colors = replicate('opposite',n) 
            1: colors = replicate(colorsi,n) 
            else: colors = colorsi 
 
         
        case len(textcolorsi) of 
            0: textcolors = replicate('opposite',n) 
            1: textcolors = replicate(textcolorsi,n) 
            else: textcolors = textcolorsi 
 
        fill = keyword_set(fill) 
        if len(usersym) == 1 : 
            usersym = 2*[[0,0],[0,1],[1,1],[1,0],[0,0]]-1 
         
        # 
        #       =====>> INITIALIZE SPACING 
        # 
        setdefaultvalue, spacing, 1.2*charsize 
        setdefaultvalue, pspacing , 3*charsize 
        xspacing = !d.x_ch_size/float(!d.x_size) * (spacing > charsize) 
        yspacing = !d.y_ch_size/float(!d.y_size) * (spacing > charsize) 
        ltor = 1# flag for left-to-right 
        if len(left) == 1 : 
            ltor = left == 1 
        if len(right) == 1 : 
            ltor = right != 1 
        ttob = 1# flag for top-to-bottom 
        if len(top) == 1 : 
            ttob = top == 1 
        if len(bottom) == 1 : 
            ttob = bottom != 1 
        xalign = ltor != 1# x alignment: 1 or 0 
        yalign = -0.5*ttob + 1# y alignment: 0.5 or 1 
        xsign = 2*ltor - 1# xspacing direction: 1 or -1 
        ysign = 2*ttob - 1# yspacing direction: 1 or -1 
        if ~ttob : 
            yspacing = -yspacing 
        if ~ltor : 
            xspacing = -xspacing 
        # 
        #       =====>> INITIALIZE POSITIONS: FIRST CALCULATE X OFFSET FOR TEXT 
        # 
        xt = 0 
        if nlpv > 0:# SKIP IF TEXT ITEMS ONLY. 
            if vertical:# CALC OFFSET FOR TEXT START 
                for i  in np.arange( 0,n): 
                    if (psym[i] == 0) and (vectorfont[i] == ''): 
                        num = (number + 1) > 3 
                    else: 
                        num = number 
                    if psym[i] < 0 :# TO SHOW CONNECTING LINE 
                        num = number > 2 
                    if psym[i] == 0: 
                        expand = linsize 
                    else: 
                        expand = 2 
                    thisxt = (expand*pspacing*(num-1)*xspacing) 
                    if ltor: 
                        xt = thisxt > xt 
                    else: 
                        xt = thisxt < xt 
        # NOW xt IS AN X OFFSET TO ALIGN ALL TEXT ENTRIES. 
        # 
        #       =====>> INITIALIZE POSITIONS: SECOND LOCATE BORDER 
        # 
         
        if !x.window[0] == !x.window[1]: 
            cgplot,/nodata,xstyle=4,ystyle=4,[0],/noerase 
        #       next line takes care of weirdness with small windows 
        pos = [min(!x.window),min(!y.window),max(!x.window),max(!y.window)] 
         
        case len(position) of 
            0: begin 
            if ltor: 
                px = pos[0] 
            else: 
                px = pos[2] 
            if ttob: 
                py = pos[3] 
            else: 
                py = pos[1] 
            if keyword_set(center): 
                if ~keyword_set(right) && ~keyword_set(left) : 
                    px = (pos[0] + pos[2])/2. - xt 
                if ~keyword_set(top) && ~keyword_set(bottom) : 
                    py = (pos[1] + pos[3])/2. + n*yspacing 
            nposition = [px,py] + [xspacing,-yspacing] 
 
        1: begin# interactive 
        message,/inform,'Place mouse at upper left corner and click any mouse button.' 
        cursor,x,y,/normal 
        nposition = [x,y] 
 
    2: begin# convert upper left corner to normal coordinates 
     
    # if keyword window is set, get the current graphics window. 
    if keyword_set(window): 
        wid = cgQuery(/current) 
        WSet, wid 
 
else: message,'Position keyword can have 0, 1, or 2 elements only. Try al_legend,/help.' 
 
 
yoff = 0.25*yspacing*ysign# VERT. OFFSET FOR SYM/LINE. 
 
x0 = nposition[0] + (margin)*xspacing# INITIAL X & Y POSITIONS 
y0 = nposition[1] - margin*yspacing + yalign*yspacing# WELL, THIS WORKS! 
# 
#       =====>> OUTPUT TEXT FOR LEGEND, ITEM BY ITEM. 
#       =====>> FOR EACH ITEM, PLACE SYM/LINE, THEN DELIMITER, 
#       =====>> THEN TEXT---UPDATING X & Y POSITIONS EACH TIME. 
#       =====>> THERE ARE A NUMBER OF EXCEPTIONS DONE WITH IF STATEMENTS. 
# 
for iclr  in np.arange( 0,clear+1): 
y = y0# STARTING X & Y POSITIONS 
x = x0 
if ltor:# SAVED WIDTH FOR DRAWING BOX 
xend = 0 
else: 
xend = 1 
 
if ttob: 
ii = [0,n-1,1] 
else: 
ii = [n-1,0,-1] 
 
for i  in np.arange( ii[0],ii[1],ii[2]+1): 
if vertical:# RESET EITHER X OR Y 
    x = x0 
else: 
    y = y0 
x = x + xspacing# UPDATE X & Y POSITIONS 
y = y - yspacing 
if nlpv == 0 :# FLAG FOR TEXT ONLY 
    goto,TEXT_ONLY 
num = number 
if (psym[i] == 0) && (vectorfont[i] == '') : 
    num = (number + 1) > 3 
if psym[i] < 0 :# TO SHOW CONNECTING LINE 
    num = number > 2 
if psym[i] == 0: 
    expand = 1 
else: 
    expand = 2 
xp = x + expand*pspacing*indgen(num)*xspacing 
if (psym[i] > 0) && (num == 1) && vertical : 
    xp = x + xt/2. 
yp = y + intarr(num) 
if vectorfont[i] == '' : 
    yp +=  yoff 
if psym[i] == 0: 
    if ltor == 1 : 
        xp = [min(xp),max(xp) -(max(xp)-min(xp))*(1.-linsize)] 
    if ltor != 1 : 
        xp = [min(xp) +(max(xp)-min(xp))*(1.-linsize),max(xp)] 
    yp = [min(yp),max(yp)]# DITTO 
if (psym[i] == 8) && (len(usersym) > 1) : 
    usersym,usersym,fill=fill,color=colors[i] 
# extra by djseed .. psym=88 means use the already defined usersymbol 
# extra by djseed .. psym=88 means use the already defined usersymbol 
 
if vectorfont[i] != '': 
    #    if (num eq 1) && vertical then xp = x + xt/2      ; IF 1, CENTERED. 
    cgText,xp,yp,vectorfont[i],width=width,color=colors[i],       size=charsize,align=xalign,charthick = charthick,/norm,font=font 
    xt = xt > width 
    xp = xp + width/2. 
else: 
    if symline and (linestyle[i] >= 0) : 
        cgPlots,xp,yp,color=colors[i]       ,/normal,linestyle=linestyle[i],psym=p_sym,symsize=symsize[i],       thick=thick[i] 
 
 
if symline : 
    x += xspacing 
 
TEXT_ONLY: 
if vertical && (vectorfont[i] == '') && symline && (linestyle[i] == -99) : 
    x=x0 + xspacing 
cgText,x,y,delimiter,width=width,/norm,color=textcolors[i],          size=charsize,align=xalign,charthick = charthick,font=font 
x += width*xsign 
if width != 0 : 
    x += 0.5*xspacing 
cgText,x,y,items[i],width=width,/norm,color=textcolors[i],size=charsize,             align=xalign,charthick=charthick,font=font 
x += width*xsign 
if ~vertical && (i < (n-1)) :# ADD INTER-ITEM SPACE 
    x += 2*xspacing 
xfinal = (x + xspacing*margin) 
if ltor:# UPDATE END X 
    xend = xfinal > xend 
else: 
    xend = xfinal < xend 
 
if (iclr < clear ): 
#       =====>> CLEAR AREA 
x = nposition[0] 
y = nposition[1] 
if vertical: 
    bottom = n 
else: 
    bottom = 1 
ywidth = - (2*margin+bottom-0.5)*yspacing 
corners = [x,y+ywidth,xend,y] 
cgColorfill,[x,xend,xend,x,x],y + [0,0,ywidth,ywidth,0],/norm, 	   color=bgcolor 
#       cgPlots,[x,xend,xend,x,x],y + [0,0,ywidth,ywidth,0], ;                 thick=2 
else: 
 
# 
#       =====>> OUTPUT BORDER 
# 
x = nposition[0] 
y = nposition[1] 
if vertical: 
    bottom = n 
else: 
    bottom = 1 
ywidth = - (2*margin+bottom-0.5)*yspacing 
corners = [x,y+ywidth,xend,y] 
if box : 
    cgPlots,[x,xend,xend,x,x,xend],y + [0,0,ywidth,ywidth,0,0],	        /norm, color = outline_color,thick=bthick 
return 
 
 
