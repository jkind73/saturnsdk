{
	if( $0 ~ /\.[Ee][Qq][Uu]/){
		sub( /[ \]+\.[Ee][Qq][Uu][ \t]+/, "," )
		printf( "\t.equ\t%s", $0 )
	}
}
