### lista_t  
<pre>
campo | tamaño | offset | alineacion  
next  | 8 bytes| 0 bytes| 8 bytes  
sum   | 4 bytes| 8 bytes| 8 bytes   se rellena con 4 de padding, ya que el proximo elemento se alinea a 8  
size  | 8 bytes| 16bytes| 8 bytes  
array | 8 bytes| 24bytes| 8 bytes   
TOTAL | 32 bytes        | 8 bytes  
</pre>
