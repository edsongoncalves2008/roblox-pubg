import importlib.util
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('builder', ROOT/'tools/build_place.py')
builder=importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
class PlaceTests(unittest.TestCase):
    def test_embedded_sources_and_placement(self):
        with tempfile.TemporaryDirectory() as directory:
            path=builder.build(Path(directory)/'game.rbxlx')
            root=E.parse(path).getroot()
            self.assertEqual(root.attrib['version'],'4')
            sources=root.findall('.//ProtectedString[@name="Source"]')
            self.assertCountEqual([s.text for s in sources],[p.read_text() for p in (ROOT/'src').rglob('*.luau')])
            self.assertEqual(len(root.findall('.//Item[@class="Script"]')),1)
            self.assertEqual(len(root.findall('.//Item[@class="LocalScript"]')),1)
            self.assertEqual(root.find('.//bool[@name="StreamingEnabled"]').text,'true')
            server=root.find('./Item[@class="ServerScriptService"]')
            self.assertIsNotNone(server.find('.//Item[@class="Script"]'))
            client=root.find('./Item[@class="StarterPlayer"]')
            self.assertIsNotNone(client.find('.//Item[@class="StarterPlayerScripts"]//Item[@class="LocalScript"]'))
    def test_deterministic_build(self):
        with tempfile.TemporaryDirectory() as directory:
            a=builder.build(Path(directory)/'a.rbxlx').read_bytes()
            b=builder.build(Path(directory)/'b.rbxlx').read_bytes()
            self.assertEqual(a,b)
if __name__=='__main__': unittest.main()
