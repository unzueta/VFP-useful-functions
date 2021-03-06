*Funcion que muestra las im�genes en un recuadro
*La variable DirImg en Procedure Init define el directorio donde est�n las imagenes
*El nombre de las imagenes deben empezar con el codigo seguido de a,b,c si son varias
*Codigo adaptado de http://yousfi.over-blog.com/2015/03/scrolling-texts-images-in-visual-foxpro.html

FUNCTION imagenesScroll
PARAMETERS codigo
PUBLIC yform
yform=Newobject("yscrollIm")
yform.Show 
READ EVENTS
RETURN
*
DEFINE CLASS yscrollIm As Form 
    BorderStyle = 3
    Top = 16
    Left = 86
    Height = 365
    Width = 803
    ShowWindow = 2
    ScrollBars = 1
    Caption = "Haga click con el bot�n izquierdo o derecho para cambiar de imagen"
    BackColor = Rgb(0,0,0)
    gnbre = 0
    Name = "Form1"

    ADD OBJECT label1 As Label WITH ;
        FontSize = 8, ;
        Anchor = 768, ;
        Alignment = 2, ;
        BackStyle = 0, ;
        Caption = "", ;
        Height = 25, ;
        Left = 164, ;
        Top = 345, ;
        Width = 477, ;
        ForeColor = Rgb(255,255,255), ;
        Name = "Label1"

    PROCEDURE my
        LPARAMETERS nButton, nShift, nXCoord, nYCoord
        Aevents( myArray, 0)
        loObject = myArray[1]
        loObject.MousePointer=15
        xrec=Substr(loObject.Name,6)
        Thisform.label1.Caption=Trans(xrec)+" -  "+Justfname(loObject.Picture)
        xw=loObject.Width
        WITH Thisform
            LOCAL yim0,yim
            yim0= .image1
            yim=Eval(".image"+Trans(Thisform.gnbre))

            DO CASE
                   CASE ! yim.Left<= 0 and Between( nXCoord ,0, loObject.Left+loObject.Width/2) &&
                    FOR i=1 To .ControlCount
                        If Lower( .Controls(i).Class)=="image"
                            .Controls(i).Left=.Controls(i).Left-xw
                        ENDIF
                    ENDFOR

                CASE ! yim0.Left>0 And Between( nXCoord ,loObject.Left+loObject.Width/2,loObject.Left+loObject.Width)
                    FOR i=1 TO .ControlCount
                        IF Lower( .Controls(i).Class)=="image"
                            .Controls(i).Left=.Controls(i).Left+xw
                        ENDIF
                    ENDFOR
            ENDCASE
        ENDWITH
    ENDPROC

    PROCEDURE Init
	    LOCAL DirImg
	    DirImg = "CATALOGO"
        LOCAL m.yrep
        *m.yrep=Getdir()
        m.yrep = CURDIR()
        m.yrep=Addbs(m.yrep)
        m.yrep = m.yrep+DirImg
        m.yrep=Addbs(m.yrep)
        gnbre=Adir(gabase,m.yrep+ALLTRIM(STR(codigo))+"*.*")
        IF gnbre>0
        CREATE CURSOR ycurs( yimage c(200))
        FOR i=1 TO gnbre
            IF Inlist(Lower(Justext(gabase(i,1))),"png","bmp","jpg","gif")
                INSERT Into ycurs Values(m.yrep+gabase(i,1))
            ENDIF 
        ENDFOR

        Thisform.gnbre=Reccount()
        *brow
        LOCATE
        IF Empty(m.yrep) Or Thisform.gnbre=0
            RETURN .F.
        ENDIF 

        WITH Thisform
            .ScrollBars=0  
            .Caption=.Caption+"("+Trans(Thisform.gnbre)+" images)"
            SELECT ycurs
            SCAN
                i=Recno()
                .AddObject("image"+Trans(i),"image")

                WITH Eval(".image"+Trans(i))
                    .Stretch=2
                    .Height=Thisform.Height-40
                    .Width=.Height*2
                    .Top=15
                    .BorderStyle=1
                    IF i=1
                        .Left=0
                    ELSE
                        .Left=Eval(".parent.image"+Trans(i-1)+".left")+.Width
                    ENDIF
                    .Picture=yimage
                    .Visible=.T.
                ENDWITH
            ENDSCAN
        ENDWITH

        LOCATE
        WITH Thisform
            .label1.Caption=Trans(Recno())+"-"+Justfname(yimage)
            FOR i=1 TO .ControlCount
                IF Lower(.Controls(i).Class)=="image"
                    Bindevent(.Controls(i),"mouseDown",Thisform,"my")
                ENDIF 
            ENDFOR
        ENDWITH
        ENDIF
    ENDPROC

    PROCEDURE Destroy
        CLEAR Events
    ENDPROC 


ENDDEFINE