import cPickle, base64
try:
	from SimpleSession.versions.v45 import beginRestore,\
	    registerAfterModelsCB, reportRestoreError, checkVersion
except ImportError:
	from chimera import UserError
	raise UserError('Cannot open session that was saved in a'
	    ' newer version of Chimera; update your version')
checkVersion([1, 4, 29390])
import chimera
from chimera import replyobj
replyobj.status('Beginning session restore...', \
    blankAfter=0)
beginRestore()

def restoreCoreModels():
	from SimpleSession.versions.v45 import init, restoreViewer, \
	     restoreMolecules, restoreColors, restoreSurfaces, \
	     restoreVRML, restorePseudoBondGroups, restoreModelAssociations
	molInfo = cPickle.loads(base64.b64decode('gAJ9cQEoVRFyaWJib25JbnNpZGVDb2xvcnECSwBOfYdxA1UJYmFsbFNjYWxlcQRLAE59h3EFVRRyaWJib25IaWRlc01haW5jaGFpbnEGSwBOfYdxB1UJcG9pbnRTaXplcQhLAE59h3EJVQRuYW1lcQpLAE59h3ELVQ9hcm9tYXRpY0Rpc3BsYXlxDEsATn2HcQ1VBWNvbG9ycQ5LAE59h3EPVQhvcHRpb25hbHEQfXERVQpwZGJIZWFkZXJzcRJdcRNVDGFyb21hdGljTW9kZXEUSwBOfYdxFVUDaWRzcRZLAE59h3EXVQ5zdXJmYWNlT3BhY2l0eXEYSwBOfYdxGVUJYXV0b2NoYWlucRpLAE59h3EbVQp2ZHdEZW5zaXR5cRxLAE59h3EdVQ1hcm9tYXRpY0NvbG9ycR5LAE59h3EfVQZoaWRkZW5xIEsATn2HcSFVCWxpbmVXaWR0aHEiSwBOfYdxI1UKc3RpY2tTY2FsZXEkSwBOfYdxJVUHZGlzcGxheXEmSwBOfYdxJ1UQYXJvbWF0aWNMaW5lVHlwZXEoSwBOfYdxKXUu'))
	resInfo = cPickle.loads(base64.b64decode('gAJ9cQEoVQZpbnNlcnRxAksATn2HcQNVC2ZpbGxEaXNwbGF5cQRLAE59h3EFVQRuYW1lcQZLAE59h3EHVQVjaGFpbnEISwBOfYdxCVUOcmliYm9uRHJhd01vZGVxCksATn2HcQtVAnNzcQxLAE59h3ENVQhtb2xlY3VsZXEOSwBOfYdxD1ULcmliYm9uQ29sb3JxEEsATn2HcRFVBWxhYmVscRJLAE59h3ETVQpsYWJlbENvbG9ycRRLAE59h3EVVQhmaWxsTW9kZXEWSwBOfYdxF1UFaXNIZXRxGEsATn2HcRlVC2xhYmVsT2Zmc2V0cRpLAE59h3EbVQhwb3NpdGlvbnEcXXEdVQ1yaWJib25EaXNwbGF5cR5LAE59h3EfVQhvcHRpb25hbHEgfXEhVQRzc0lkcSJLAE59h3EjdS4='))
	atomInfo = cPickle.loads(base64.b64decode('gAJ9cQEoVQdyZXNpZHVlcQJLAE59h3EDVQh2ZHdDb2xvcnEESwBOfYdxBVUEbmFtZXEGSwBOfYdxB1UDdmR3cQhLAE59h3EJVQ5zdXJmYWNlRGlzcGxheXEKSwBOfYdxC1UFY29sb3JxDEsATn2HcQ1VCWlkYXRtVHlwZXEOSwBOfYdxD1UGYWx0TG9jcRBLAE59h3ERVQVsYWJlbHESSwBOfYdxE1UOc3VyZmFjZU9wYWNpdHlxFEsATn2HcRVVB2VsZW1lbnRxFksATn2HcRdVCmxhYmVsQ29sb3JxGEsATn2HcRlVDHN1cmZhY2VDb2xvcnEaSwBOfYdxG1UGcmFkaXVzcRxLAE59h3EdVQtsYWJlbE9mZnNldHEeSwBOfYdxH1UPc3VyZmFjZUNhdGVnb3J5cSBLAE59h3EhVQhkcmF3TW9kZXEiSwBOfYdxI1UIb3B0aW9uYWxxJH1xJVUHZGlzcGxheXEmSwBOfYdxJ3Uu'))
	bondInfo = cPickle.loads(base64.b64decode('gAJ9cQEoVQVhdG9tc3ECXXEDVQVsYWJlbHEESwBOfYdxBVUGcmFkaXVzcQZLAE59h3EHVQtsYWJlbE9mZnNldHEISwBOfYdxCVUIZHJhd01vZGVxCksATn2HcQtVCG9wdGlvbmFscQx9cQ1VB2Rpc3BsYXlxDksATn2HcQ91Lg=='))
	crdInfo = cPickle.loads(base64.b64decode('gAJ9cQEu'))
	surfInfo = {'category': (0, None, {}), 'probeRadius': (0, None, {}), 'pointSize': (0, None, {}), 'name': [], 'density': (0, None, {}), 'colorMode': (0, None, {}), 'useLighting': (0, None, {}), 'transparencyBlendMode': (0, None, {}), 'molecule': [], 'smoothLines': (0, None, {}), 'lineWidth': (0, None, {}), 'allComponents': (0, None, {}), 'twoSidedLighting': (0, None, {}), 'oneTransparentLayer': (0, None, {}), 'drawMode': (0, None, {}), 'display': (0, None, {}), 'customColors': []}
	vrmlInfo = {'subid': (0, None, {}), 'display': (0, None, {}), 'id': (0, None, {}), 'vrmlString': [], 'name': (0, None, {})}
	colors = {'Ru': ((0.141176, 0.560784, 0.560784), 1, 'default'), 'Re': ((0.14902, 0.490196, 0.670588), 1, 'default'), 'Rf': ((0.8, 0, 0.34902), 1, 'default'), 'Ra': ((0, 0.490196, 0), 1, 'default'), 'Rb': ((0.439216, 0.180392, 0.690196), 1, 'default'), 'Rn': ((0.258824, 0.509804, 0.588235), 1, 'default'), 'Rh': ((0.0392157, 0.490196, 0.54902), 1, 'default'), 'Be': ((0.760784, 1, 0), 1, 'default'), 'Ba': ((0, 0.788235, 0), 1, 'default'), 'Bh': ((0.878431, 0, 0.219608), 1, 'default'), 'Bi': ((0.619608, 0.309804, 0.709804), 1, 'default'), 'Bk': ((0.541176, 0.309804, 0.890196), 1, 'default'), 'Br': ((0.65098, 0.160784, 0.160784), 1, 'default'), 'H': ((1, 1, 1), 1, 'default'), 'P': ((1, 0.501961, 0), 1, 'default'), 'Os': ((0.14902, 0.4, 0.588235), 1, 'default'), 'Ge': ((0.4, 0.560784, 0.560784), 1, 'default'), 'Gd': ((0.270588, 1, 0.780392), 1, 'default'), 'Ga': ((0.760784, 0.560784, 0.560784), 1, 'default'), 'Pr': ((0.85098, 1, 0.780392), 1, 'default'), 'Pt': ((0.815686, 0.815686, 0.878431), 1, 'default'), 'Pu': ((0, 0.419608, 1), 1, 'default'), 'C': ((0.564706, 0.564706, 0.564706), 1, 'default'),
'Pb': ((0.341176, 0.34902, 0.380392), 1, 'default'), 'Pa': ((0, 0.631373, 1), 1, 'default'), 'Pd': ((0, 0.411765, 0.521569), 1, 'default'), 'Cd': ((1, 0.85098, 0.560784), 1, 'default'), 'Po': ((0.670588, 0.360784, 0), 1, 'default'), 'Pm': ((0.639216, 1, 0.780392), 1, 'default'), 'Hs': ((0.901961, 0, 0.180392), 1, 'default'), 'Ho': ((0, 1, 0.611765), 1, 'default'), 'Hf': ((0.301961, 0.760784, 1), 1, 'default'), 'Hg': ((0.721569, 0.721569, 0.815686), 1, 'default'), 'He': ((0.85098, 1, 1), 1, 'default'), 'Md': ((0.701961, 0.0509804, 0.65098), 1, 'default'), 'Mg': ((0.541176, 1, 0), 1, 'default'), 'K': ((0.560784, 0.25098, 0.831373), 1, 'default'), 'Mn': ((0.611765, 0.478431, 0.780392), 1, 'default'), 'O': ((1, 0.0509804, 0.0509804), 1, 'default'), 'Mt': ((0.921569, 0, 0.14902), 1, 'default'), 'S': ((1, 1, 0.188235), 1, 'default'), 'W': ((0.129412, 0.580392, 0.839216), 1, 'default'), 'Zn': ((0.490196, 0.501961, 0.690196), 1, 'default'), 'Eu': ((0.380392, 1, 0.780392), 1, 'default'), 'Zr': ((0.580392, 0.878431, 0.878431), 1, 'default'), 'Er': ((0, 0.901961, 0.458824), 1, 'default'),
'Ni': ((0.313725, 0.815686, 0.313725), 1, 'default'), 'No': ((0.741176, 0.0509804, 0.529412), 1, 'default'), 'Na': ((0.670588, 0.360784, 0.94902), 1, 'default'), 'Nb': ((0.45098, 0.760784, 0.788235), 1, 'default'), 'Nd': ((0.780392, 1, 0.780392), 1, 'default'), 'Ne': ((0.701961, 0.890196, 0.960784), 1, 'default'), 'Np': ((0, 0.501961, 1), 1, 'default'), 'Fr': ((0.258824, 0, 0.4), 1, 'default'), 'Fe': ((0.878431, 0.4, 0.2), 1, 'default'), 'Fm': ((0.701961, 0.121569, 0.729412), 1, 'default'), 'B': ((1, 0.709804, 0.709804), 1, 'default'), 'F': ((0.564706, 0.878431, 0.313725), 1, 'default'), 'Sr': ((0, 1, 0), 1, 'default'), 'N': ((0.188235, 0.313725, 0.972549), 1, 'default'), 'Kr': ((0.360784, 0.721569, 0.819608), 1, 'default'), 'Si': ((0.941176, 0.784314, 0.627451), 1, 'default'), 'Sn': ((0.4, 0.501961, 0.501961), 1, 'default'), 'Sm': ((0.560784, 1, 0.780392), 1, 'default'), 'V': ((0.65098, 0.65098, 0.670588), 1, 'default'), 'Sc': ((0.901961, 0.901961, 0.901961), 1, 'default'), 'Sb': ((0.619608, 0.388235, 0.709804), 1, 'default'), 'Sg': ((0.85098, 0, 0.270588), 1, 'default'),
'Se': ((1, 0.631373, 0), 1, 'default'), 'Co': ((0.941176, 0.564706, 0.627451), 1, 'default'), 'Cm': ((0.470588, 0.360784, 0.890196), 1, 'default'), 'Cl': ((0.121569, 0.941176, 0.121569), 1, 'default'), 'Ca': ((0.239216, 1, 0), 1, 'default'), 'Cf': ((0.631373, 0.211765, 0.831373), 1, 'default'), 'Ce': ((1, 1, 0.780392), 1, 'default'), 'Xe': ((0.258824, 0.619608, 0.690196), 1, 'default'), 'Tm': ((0, 0.831373, 0.321569), 1, 'default'), 'Cs': ((0.341176, 0.0901961, 0.560784), 1, 'default'), 'Cr': ((0.541176, 0.6, 0.780392), 1, 'default'), 'Cu': ((0.784314, 0.501961, 0.2), 1, 'default'), 'La': ((0.439216, 0.831373, 1), 1, 'default'), 'Li': ((0.8, 0.501961, 1), 1, 'default'), 'Tl': ((0.65098, 0.329412, 0.301961), 1, 'default'), 'Lu': ((0, 0.670588, 0.141176), 1, 'default'), 'Lr': ((0.780392, 0, 0.4), 1, 'default'), 'Th': ((0, 0.729412, 1), 1, 'default'), 'Ti': ((0.74902, 0.760784, 0.780392), 1, 'default'), 'Te': ((0.831373, 0.478431, 0), 1, 'default'), 'Tb': ((0.188235, 1, 0.780392), 1, 'default'), 'Tc': ((0.231373, 0.619608, 0.619608), 1, 'default'), 'Ta': ((0.301961, 0.65098, 1), 1, 'default'),
'Yb': ((0, 0.74902, 0.219608), 1, 'default'), 'Db': ((0.819608, 0, 0.309804), 1, 'default'), 'Dy': ((0.121569, 1, 0.780392), 1, 'default'), 'At': ((0.458824, 0.309804, 0.270588), 1, 'default'), 'I': ((0.580392, 0, 0.580392), 1, 'default'), 'U': ((0, 0.560784, 1), 1, 'default'), 'Y': ((0.580392, 1, 1), 1, 'default'), 'Ac': ((0.439216, 0.670588, 0.980392), 1, 'default'), 'Ag': ((0.752941, 0.752941, 0.752941), 1, 'default'), 'Ir': ((0.0901961, 0.329412, 0.529412), 1, 'default'), 'Am': ((0.329412, 0.360784, 0.94902), 1, 'default'), 'Al': ((0.74902, 0.65098, 0.65098), 1, 'default'), 'As': ((0.741176, 0.501961, 0.890196), 1, 'default'), 'Ar': ((0.501961, 0.819608, 0.890196), 1, 'default'), 'Au': ((1, 0.819608, 0.137255), 1, 'default'), 'Es': ((0.701961, 0.121569, 0.831373), 1, 'default'), 'In': ((0.65098, 0.458824, 0.45098), 1, 'default'), 'Mo': ((0.329412, 0.709804, 0.709804), 1, 'default')}
	materials = {'default': ((3.7, 3.7, 3.7), 70)}
	pbInfo = {'category': ['distance monitor'], 'bondInfo': [{'color': (0, None, {}), 'atoms': [], 'label': (0, None, {}), 'halfbond': (0, None, {}), 'labelColor': (0, None, {}), 'drawMode': (0, None, {}), 'display': (0, None, {})}], 'lineType': (1, 2, {}), 'color': (1, 0, {}), 'showStubBonds': (1, False, {}), 'lineWidth': (1, 1, {}), 'stickScale': (1, 1, {}), 'id': [-2]}
	modelAssociations = {}
	colorInfo = {0: ('yellow', (1, 1, 0, 1)), 1: ('green', (0, 1, 0, 1))}
	viewerInfo = {'cameraAttrs': {'center': (62.4543, 63.4437, 62.7416), 'fieldOfView': 19.2318, 'nearFar': (116.633, 8.84971), 'ortho': True, 'eyeSeparation': 50.8, 'focal': 62.7416}, 'viewerAttrs': {'silhouetteColor': None, 'clipping': False, 'showSilhouette': False, 'viewSize': 54.7495, 'depthCueRange': (0.5, 1), 'silhouetteWidth': 1, 'depthCue': True, 'highlight': 0, 'scaleFactor': 1}, 'viewerHL': 1, 'cameraMode': 'mono', 'detail': 1, 'viewerFog': None, 'viewerBG': None}

	replyobj.status("Initializing session restore...", blankAfter=0)
	init(colorInfo)
	replyobj.status("Restoring colors...", blankAfter=0)
	restoreColors(colors, materials)
	replyobj.status("Restoring molecules...", blankAfter=0)
	restoreMolecules(molInfo, resInfo, atomInfo, bondInfo, crdInfo)
	replyobj.status("Restoring surfaces...", blankAfter=0)
	restoreSurfaces(surfInfo)
	replyobj.status("Restoring VRML models...", blankAfter=0)
	restoreVRML(vrmlInfo)
	replyobj.status("Restoring pseudobond groups...", blankAfter=0)
	restorePseudoBondGroups(pbInfo)
	replyobj.status("Restoring model associations...", blankAfter=0)
	restoreModelAssociations(modelAssociations)
	replyobj.status("Restoring camera...", blankAfter=0)
	restoreViewer(viewerInfo)

try:
	restoreCoreModels()
except:
	reportRestoreError("Error restoring core models")

	replyobj.status("Restoring extension info...", blankAfter=0)

