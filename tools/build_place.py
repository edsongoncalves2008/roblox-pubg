"""Build a standalone Roblox XML place from the same sources used by Rojo."""
from pathlib import Path
import xml.etree.ElementTree as E
ROOT = Path(__file__).resolve().parents[1]

def build(destination):
    doc=E.Element('roblox',version='4')
    E.SubElement(doc,'External').text='null'
    E.SubElement(doc,'External').text='nil'
    count=0
    def item(parent, cls, name):
        nonlocal count
        count+=1
        node=E.SubElement(parent,'Item',{'class':cls,'referent':f'RBX{count}'})
        props=E.SubElement(node,'Properties')
        E.SubElement(props,'string',name='Name').text=name
        return node,props
    workspace,props=item(doc,'Workspace','Workspace')
    E.SubElement(props,'bool',name='StreamingEnabled').text='true'
    for name,value in [('StreamingMinRadius',128),('StreamingTargetRadius',512)]:
        E.SubElement(props,'int',name=name).text=str(value)
    item(workspace,'Terrain','Terrain')
    shared,_=item(doc,'ReplicatedStorage','ReplicatedStorage')
    shared,_=item(shared,'Folder','Shared')
    server,_=item(doc,'ServerScriptService','ServerScriptService')
    server,_=item(server,'Folder','Game')
    starter,_=item(doc,'StarterPlayer','StarterPlayer')
    client,_=item(starter,'StarterPlayerScripts','StarterPlayerScripts')
    client,_=item(client,'Folder','Game')
    for directory,parent in [('shared',shared),('server',server),('client',client)]:
        for source in sorted((ROOT/'src'/directory).glob('*.luau')):
            cls='Script' if source.name.endswith('.server.luau') else 'LocalScript' if source.name.endswith('.client.luau') else 'ModuleScript'
            name=source.name.split('.')[0]
            _,props=item(parent,cls,name)
            E.SubElement(props,'ProtectedString',name='Source').text=source.read_text()
    destination.parent.mkdir(parents=True,exist_ok=True)
    E.indent(doc)
    E.ElementTree(doc).write(destination,encoding='utf-8',xml_declaration=True)
    return destination

if __name__=='__main__':
    print(build(ROOT/'build'/'JungleBattlegrounds.rbxlx'))
