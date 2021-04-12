    ],
   'version': 2,
  }
 from VolumeViewer import session
 session.restore_volume_data_state(volume_data_state)

try:
  restore_volume_data()
except:
  reportRestoreError('Error restoring volume data')


def restore_volume_dialog():
 volume_dialog_state = \
  {
   'adjust_camera': 0,
   'auto_show_subregion': 0,
   'box_padding': '0',
   'class': 'Volume_Dialog_State',
   'data_cache_size': '512',
   'focus_volume': 170109804,
   'geometry': '380x308+947+531',
   'histogram_active_order': [ 1, 0, ],
   'histogram_volumes': [ 167683980, 170109804, ],
   'immediate_update': 1,
   'initial_colors': (
     ( 0.69999999999999996, 0.69999999999999996, 0.69999999999999996, 1, ),
     ( 1, 1, 0.69999999999999996, 1, ),
     ( 0.69999999999999996, 1, 1, 1, ),
     ( 0.69999999999999996, 0.69999999999999996, 1, 1, ),
     ( 1, 0.69999999999999996, 1, 1, ),
     ( 1, 0.69999999999999996, 0.69999999999999996, 1, ),
     ( 0.69999999999999996, 1, 0.69999999999999996, 1, ),
     ( 0.90000000000000002, 0.75, 0.59999999999999998, 1, ),
     ( 0.59999999999999998, 0.75, 0.90000000000000002, 1, ),
     ( 0.80000000000000004, 0.80000000000000004, 0.59999999999999998, 1, ),
    ),
   'is_visible': True,
   'max_histograms': '3',
   'representation': 'surface',
   'selectable_subregions': 0,
   'show_on_open': 1,
   'show_plane': 1,
   'shown_panels': [ 'Threshold and Color', 'Display style', ],
   'subregion_button': 'button 2',
   'use_initial_colors': 1,
   'version': 12,
   'voxel_limit_for_open': '256',
   'voxel_limit_for_plane': '256',
   'zone_radius': 2.0,
  }
 from VolumeViewer import session
 session.restore_volume_dialog_state(volume_dialog_state)

try:
  restore_volume_dialog()
except:
  reportRestoreError('Error restoring volume dialog')


def restoreLightController():
	import Lighting
	c = Lighting.get().setFromParams({'quality': 'normal', 'shininess': (70.0, (3.7000000000000002, 3.7000000000000002, 3.7000000000000002), 3.7000000000000002), 'key': (True, (1.0, 1.0, 1.0), 0.86130702495574951, (1.0, 1.0, 1.0), 0.86130702495574951, (0.18520734050478133, -0.1989264077314486, 0.96235467751251014)), 'fill': (True, (1.0, 1.0, 1.0), 0.20000000298023224, (1.0, 1.0, 1.0), 0.60000002384185791, (0.53834049201544476, 0.26404726531039435, 0.8002927941314173))})
try:
	restoreLightController()
except:
	reportRestoreError("Error restoring lighting parameters")


def restoreSession_RibbonStyleEditor():
	import SimpleSession
	import RibbonStyleEditor
	userScalings = [('licorice', [[0.35, 0.35], [0.35, 0.35], [0.35, 0.35], [0.35, 0.35, 0.35, 0.35], [0.35, 0.35]])]
	userXSections = []
	userResidueClasses = []
	residueData = []
	flags = RibbonStyleEditor.NucleicDefault1
	SimpleSession.registerAfterModelsCB(RibbonStyleEditor.restoreState,
				(userScalings, userXSections,
				userResidueClasses, residueData, flags))
try:
	restoreSession_RibbonStyleEditor()
except:
	reportRestoreError("Error restoring RibbonStyleEditor state")
geomData = {'AxisManager': {}, 'PlaneManager': {}}

try:
	from StructMeasure.Geometry import geomManager
	geomManager._restoreSession(geomData)
except:
	reportRestoreError("Error restoring geometry objects in session")


def restoreMidasText():
	from Midas import midas_text
	midas_text.aliases = {}
	midas_text.userSurfCategories = {}

try:
	restoreMidasText()
except:
	reportRestoreError('Error restoring Midas text state')


def restoreMidasBase():
	import chimera
	from SimpleSession import modelMap, modelOffset
	def deformatPosition(pos):
		xfDict = {}
		for molId, xfData in pos[5].items():
			mid, subid = molId
			trData, rotData = xfData
			xf = chimera.Xform.translation(*trData)
			xf.rotate(*rotData)
			xfDict[(mid+modelOffset, subid)] = xf
		try:
			from chimera.misc import KludgeWeakWrappyDict
			clipDict = KludgeWeakWrappyDict("Model")
		except ImportError:
			from weakref import WeakKeyDictionary
			clipDict = WeakKeyDictionary()
		for clipID, clipInfo in pos[6].items():
			mid, subid, className = clipID
			models = [m for m in modelMap.get((mid, subid), [])
					if m.__class__.__name__ == className]
			if not models:
				continue
			useClip, ox, oy, oz, nx, ny, nz, useThick, thickness = clipInfo
			if useClip:
				origin = chimera.Point(ox, oy, oz)
				normal = chimera.Vector(nx, ny, nz)
				plane = chimera.Plane(origin, normal)
			else:
				plane = chimera.Plane()
			for m in models:
				clipDict[m] = (useClip, plane,
							useThick, thickness)
		return pos[:5] + (xfDict, clipDict) + pos[7:]
	formattedPositions = {}
	positions = {}
	for name, fpos in formattedPositions.items():
		positions[name] = deformatPosition(fpos)
	import Midas
	if modelOffset == 0:
		Midas.positions.clear()
	Midas.positions.update(positions)
	positionStack = []
	Midas._positionStack = map(deformatPosition, positionStack)

def delayedMidasBase():
	try:
		restoreMidasBase()
	except:
		reportRestoreError('Error restoring Midas base state')
import SimpleSession
SimpleSession.registerAfterModelsCB(delayedMidasBase)


try:
	import StructMeasure
	from StructMeasure.DistMonitor import restoreDistances
	registerAfterModelsCB(restoreDistances, 1)
except:
	reportRestoreError("Error restoring distances in session")


def restoreRemainder():
	from SimpleSession.versions.v45 import restoreWindowSize, \
	     restoreOpenStates, restoreSelections, restoreFontInfo, \
	     restoreOpenModelsAttrs, restoreModelClip

	curSelIds =  []
	savedSels = []
	openModelsAttrs = { 'cofrMethod': 4 }
	windowSize = (943, 1023)
	xformMap = {}
	fontInfo = {'face': ('Sans Serif', 'Normal', 16)}
	clipPlaneInfo = {}

	replyobj.status("Restoring window...", blankAfter=0)
	restoreWindowSize(windowSize)
	replyobj.status("Restoring open states...", blankAfter=0)
	restoreOpenStates(xformMap)
	replyobj.status("Restoring font info...", blankAfter=0)
	restoreFontInfo(fontInfo)
	replyobj.status("Restoring selections...", blankAfter=0)
	restoreSelections(curSelIds, savedSels)
	replyobj.status("Restoring openModel attributes...", blankAfter=0)
	restoreOpenModelsAttrs(openModelsAttrs)
	replyobj.status("Restoring model clipping...", blankAfter=0)
	restoreModelClip(clipPlaneInfo)

	replyobj.status("Restoring remaining extension info...", blankAfter=0)
try:
	restoreRemainder()
except:
	reportRestoreError("Error restoring post-model state")
from SimpleSession.versions.v45 import makeAfterModelsCBs
makeAfterModelsCBs()

from SimpleSession.versions.v45 import endRestore
replyobj.status('Finishing restore...', blankAfter=0)
endRestore()
replyobj.status('Restore finished.')
