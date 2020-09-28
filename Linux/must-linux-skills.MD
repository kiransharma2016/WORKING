#### removing blank line in a file using sed

sed -i '/^$/d' filename

####  deleting lines in vi 

There are different ways to do it. one easy way, or the way i do are these two


esc:num,num$d
eg esc :1$d or exc 1,2$d

#### removing line starting with # using sed
