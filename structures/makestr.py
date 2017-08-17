# This code is to help use wien2k's built tool makestruct
# to generate a struct file.  
# class ================================================================
class makestr:
    def vec2str(self,vec):
        # convert a list to string, e.g. [1,2,3] -> '1 2 3'
        vec_str=[' '+str(val)+' ' for val in vec]
        
        return ''.join(vec_str)
    def atom_list(self,atom_type):
        # convert atom list to standard format,e.g [2,'Si] -> ['Si, Si']
        all_atom=[]
        for n in range(0,int(len(atom_type)/2)):
            all_atom.extend(((atom_type[2*n+1]+' ')*atom_type[2*n]).split())
            
        return all_atom
        
    def coord_list(self,atom_coord):
        # convert atom coordinate to standard format, 
        # e.g., [[1,2,3],[4,5,6]..] -> [['1 2 3'],['4 5 6'],...]
        atom_coord_str=[self.vec2str(vec) for vec in atom_coord]
        return atom_coord_str
        
    def header(self,project_name,lat_const,lat_angle,atom_type):
        txt=[]
        txt.append('#!/bin/bash -l\n')
        txt.append('makestruct << go!\n') 
        txt.append(project_name+'\n')
        txt.append('S\n') 
        txt.append(sgroup+'\n')
        txt.append('ANG\n')
        txt.append(self.vec2str(lat_const)+'\n')
        txt.append(self.vec2str(lat_angle)+'\n')
        txt.append(str(sum(atom_type[0::2]))+'\n')

        return txt
    
    def write_bash(self,wkdir,project_name,lat_const,lat_angle,atom_type,atom_coord):
        header=self.header(project_name,lat_const,lat_angle,atom_type)
        atom_list=self.atom_list(atom_type)
        coord_list=self.coord_list(atom_coord)
        txt=header
        for n, at in enumerate(atom_list):
            txt.append(at+'\n')
            txt.append(coord_list[n]+'\n')
            #txt.append(''.join(coord_list[3*n:3*n+3])+'\n')
            
        if (wkdir[-1]!='\\') & (wkdir[-1]!='/'):
            wkdir=wkdir+'/'
        
        with open(wkdir+project_name+'_str.sh','w') as file:
            file.writelines(txt)          
            file.write('go!')
        

# Main =================================
if __name__=='__main__':
    # ----  parameters ---- 
    wkdir='C:\\MyDrive\\Work\\Li2OsO3\\str'
    project_name='Li2OsO3'
    sgroup='C2/m'
    lat_const=[5.170, 8.802, 5.1254]
    lat_angle=[90.0, 110.35, 90.0]
    atom_type=[1,'Os',3,'Li',2,'O']
    atom_coord=\
    [[0,1/3,0],[0,0,0],[0,0.819,0.5],[0.0,0.5,0.5],[0.245,0.321,0.759],[0.255,0,0.773]] 

    # ---- Main ----
    w2k_str=makestr()
    w2k_str.write_bash(wkdir,project_name,lat_const,lat_angle,atom_type,atom_coord)