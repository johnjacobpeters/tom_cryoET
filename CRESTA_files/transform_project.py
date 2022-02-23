
from scipy.spatial.transform import Rotation as R
import csv
import numpy as n
from skspatial.objects import Points, Plane
import pylab as p
from skspatial.transformation import transform_coordinates
from skspatial.plotting import plot_3d
import os, pickle, argparse
import math
import pandas as pd
from glob import glob
from copy import deepcopy
from mmap import mmap
from tqdm import tqdm
from matplotlib import pyplot as plt

class transformall(object):

    def __init__(self):
        self.lab = []
        self.X = []
        self.Y = []
        self.Z = []
        self.Rot = []
        self.Tilt = []
        self.Psi = []
        self.transformedpoints = []
        self.Xmem = []
        self.Ymem = []
        self.Zmem = []
        self.Xcen = []
        self.Ycen = []
        self.Zcen = []
        self.rot = []
        self.input_stars = []
        self.data = {}
        self.dataframes = {}
        self.labels = {
            'data_model_general': {
                'rlnReferenceDimensionality': {'type': int, 'found': False},
                'rlnDataDimensionality': {'type': int, 'found': False},
                'rlnOriginalImageSize': {'type': int, 'found': False},
                'rlnCurrentResolution': {'type': float, 'found': False},
                'rlnCurrentImageSize': {'type': int, 'found': False},
                'rlnPaddingFactor': {'type': float, 'found': False},
                'rlnIsHelix': {'type': bool, 'found': False},
                'rlnFourierSpaceInterpolator': {'type': bool, 'found': False},
                'rlnMinRadiusNnInterpolation': {'type': int, 'found': False},
                'rlnPixelSize': {'type': float, 'found': False},
                'rlnNrClasses': {'type': int, 'found': False},
                'rlnNrBodies': {'type': int, 'found': False},
                'rlnNrGroups': {'type': int, 'found': False},
                'rlnTau2FudgeFactor': {'type': float, 'found': False},
                'rlnNormCorrectionAverage': {'type': float, 'found': False},
                'rlnSigmaOffsetsAngst': {'type': float, 'found': False},
                'rlnOrientationalPriorMode': {'type': bool, 'found': False},
                # 'rlnSigmaPriorMode':{'type':bool, 'found':False},
                'rlnSigmaPriorRotAngle': {'type': float, 'found': False},
                'rlnSigmaPriorTiltAngle': {'type': float, 'found': False},
                'rlnSigmaPriorPsiAngle': {'type': float, 'found': False},
                'rlnLogLikelihood': {'type': float, 'found': False},
                'rlnAveragePmax': {'type': float, 'found': False}
            },
            'data_model_classes': {
                'rlnReferenceImage': {'type': str, 'col': -1, 'found': False},
                'rlnClassDistribution': {'type': float, 'col': -1, 'found': False},
                'rlnAccuracyRotations': {'type': float, 'col': -1, 'found': False},
                'rlnAccuracyTranslationsAngst': {'type': float, 'col': -1, 'found': False},
                'rlnEstimatedResolution': {'type': float, 'col': -1, 'found': False},
                'rlnOverallFourierCompleteness': {'type': float, 'col': -1, 'found': False}
            },
            'data_model_class_': {
                'rlnSpectralIndex': {'type': int, 'col': -1, 'found': False},
                'rlnResolution': {'type': float, 'col': -1, 'found': False},
                'rlnAngstromResolution': {'type': float, 'col': -1, 'found': False},
                'rlnSsnrMap': {'type': float, 'col': -1, 'found': False},
                'rlnGoldStandardFsc': {'type': float, 'col': -1, 'found': False},
                'rlnFourierCompleteness': {'type': float, 'col': -1, 'found': False},
                'rlnReferenceSigma2': {'type': float, 'col': -1, 'found': False},
                'rlnReferenceTau2': {'type': float, 'col': -1, 'found': False},
                'rlnSpectralOrientabilityContribution': {'type': float, 'col': -1, 'found': False},
                # this one seems to not be present in iteration 1 of Class3D... skip iteration 1 for now
            },
            'data_model_groups': {
                'rlnGroupNumber': {'type': int, 'col': -1, 'found': False},
                'rlnGroupName': {'type': str, 'col': -1, 'found': False},
                'rlnGroupNrParticles': {'type': int, 'col': -1, 'found': False},
                'rlnGroupScaleCorrection': {'type': float, 'col': -1, 'found': False}
            },
            'data_model_group_': {
                'rlnSpectralIndex': {'type': int, 'col': -1, 'found': False},
                'rlnResolution': {'type': float, 'col': -1, 'found': False},
                'rlnSigma2Noise': {'type': float, 'col': -1, 'found': False},
            },
            'data_model_pdf_orient_class_': {
                'rlnOrientationDistribution': {'type': float, 'col': -1, 'found': False}
            },
            'data_particles': {
                'rlnMicrographName': {'type': str, 'col': -1, 'found': False},
                'rlnCoordinateX': {'type': float, 'col': -1, 'found': False},
                'rlnCoordinateY': {'type': float, 'col': -1, 'found': False},
                'rlnCoordinateZ': {'type': float, 'col': -1, 'found': False},
                'rlnImageName': {'type': str, 'col': -1, 'found': False},
                'rlnCtfImage': {'type': str, 'col': -1, 'found': False},
                'rlnGroupNumber': {'type': int, 'col': -1, 'found': False},
                'rlnAngleRot': {'type': float, 'col': -1, 'found': False},
                'rlnAngleTilt': {'type': float, 'col': -1, 'found': False},
                'rlnAnglePsi': {'type': float, 'col': -1, 'found': False},
                'rlnAngleTiltPrior': {'type': float, 'col': -1, 'found': False},
                'rlnAnglePsiPrior': {'type': float, 'col': -1, 'found': False},
                'rlnOpticsGroup': {'type': int, 'col': -1, 'found': False},
                'rlnOriginXAngst': {'type': float, 'col': -1, 'found': False},
                'rlnOriginYAngst': {'type': float, 'col': -1, 'found': False},
                'rlnOriginZAngst': {'type': float, 'col': -1, 'found': False},
                'rlnClassNumber': {'type': int, 'col': -1, 'found': False},
                'rlnNormCorrection': {'type': float, 'col': -1, 'found': False},
                'rlnLogLikeliContribution': {'type': float, 'col': -1, 'found': False},
                'rlnMaxValueProbDistribution': {'type': float, 'col': -1, 'found': False},
                'rlnNrOfSignificantSamples': {'type': int, 'col': -1, 'found': False}
            },
            'data_optics': {
                'rlnOpticsGroup': {'type': int, 'col': -1, 'found': False},
                'rlnOpticsGroupName': {'type': str, 'col': -1, 'found': False},
                'rlnImagePixelSize': {'type': float, 'col': -1, 'found': False},
                'rlnImageSize': {'type': int, 'col': -1, 'found': False},
                'rlnImageDimensionality': {'type': int, 'col': -1, 'found': False},
                'rlnAmplitudeContrast': {'type': float, 'col': -1, 'found': False},
                'rlnSphericalAberration': {'type': float, 'col': -1, 'found': False},
                'rlnVoltage': {'type': float, 'col': -1, 'found': False}
            }
        }
        return

    def transformandplot(self, namecsv, partcount, todisplay):
        with open(str(namecsv), mode='r')as file:
            # reading the CSV file
            csvFile = csv.reader(file)
            for row in csvFile:
                self.lab.append(row[0])
                self.X.append(row[1])
                self. Y.append(row[2])
                self.Z.append(row[3])
                self.Rot.append(row[4])
                self.Tilt.append(row[5])
                self.Psi.append(row[6])
            points = n.array([self.X, self.Y, self.Z], dtype=float)
            points = (n.transpose(points))
            points = Points(points)
            angles = n.array([self.Rot, self.Tilt, self.Psi], dtype=float)
            angles = n.transpose(angles)
            angles = Points(angles)

            # initialize loop variables
            pointsloop = points[self.lab.index('1'):self.lab.index('2'), 0:3]
            anglesloop = angles[self.lab.index('1'):self.lab.index('2'), 0:3]
            rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)
            rotatedpointsloop = rot.apply(pointsloop)

            # loop through transformations
            for x in range(partcount-todisplay, partcount):
                pointsloop = points[self.lab.index(str(x)):self.lab.index(str(x + 1)), 0:3]
                anglesloop = angles[self.lab.index(str(x)):self.lab.index(str(x + 1)), 0:3]
                rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)
                rotatedpointsloop = rot.apply(pointsloop)

                # add plot feature to points
                rotatedpointsloop = Points(rotatedpointsloop)
                pointsloop = Points(pointsloop)

                # find best fit plane of rotated points
                planeloop = Plane.best_fit(rotatedpointsloop)
                planeorigloop = Plane.best_fit(pointsloop)

                # visualize points, best fit planes
                plot_3d(rotatedpointsloop.plotter(c='r', s=50, depthshade=False),
                        pointsloop.plotter(c='k', s=50, depthshade=False),
                        planeorigloop.plotter(alpha=0.2, lims_x=(-35, 35), lims_y=(-35, 55)),
                        planeloop.plotter(alpha=0.2, lims_x=(-35, 35), lims_y=(-35, 55)))
                plt.xlabel('X')
                plt.ylabel('Y')
                p.show()
        return

    # python transform_project.py summary --csv subforproject20210208.csv --partcount 198
    def transformnoplot(self, namecsv, partcount, lst=None):
        with open(namecsv, mode='r')as file:
            # reading the CSV file
            csvFile = csv.reader(file)
            for row in csvFile:
                self.lab.append(row[0])
                self.X.append(row[1])
                self. Y.append(row[2])
                self.Z.append(row[3])
                self.Rot.append(row[4])
                self.Tilt.append(row[5])
                self.Psi.append(row[6])
            points = n.array([self.X, self.Y, self.Z], dtype=float)
            points = (n.transpose(points))
            points = Points(points)
            angles = n.array([self.Rot, self.Tilt, self.Psi], dtype=float)
            angles = n.transpose(angles)
            angles = Points(angles)
            vectors_basis = [[1, 0, 0], [0, 1, 0]]

            # initialize loop variables
            pointsloop = points[self.lab.index('1'):self.lab.index('2'), 0:3]
            anglesloop = angles[self.lab.index('1'):self.lab.index('2'), 0:3]
            rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)
            rotatedpointsloop = rot.apply(pointsloop)
            transpoints = n.zeros((1, 2))

            # loop through transformations
            for x in range(1, partcount):
                pointsloop = points[self.lab.index(str(x)):self.lab.index(str(x + 1)), 0:3]
                anglesloop = angles[self.lab.index(str(x)):self.lab.index(str(x + 1)), 0:3]
                rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)
                rotatedpointsloop = rot.apply(pointsloop)

                # add plot feature to points
                rotatedpointsloop = Points(rotatedpointsloop)
                pointsloop = Points(pointsloop)

                # find best fit plane of rotated points
                planeloop = Plane.best_fit(rotatedpointsloop)
                planeorigloop = Plane.best_fit(pointsloop)

                #transform points and build array
                transpoints = n.concatenate((transpoints, transform_coordinates(rotatedpointsloop, [0, 0, 0], vectors_basis)))
                # figure making
                transpointsloop = transform_coordinates(rotatedpointsloop, [0, 0, 0], vectors_basis)
                fig = plt.figure()
                ax = fig.gca()
                ax.scatter(transpointsloop[:, 0], transpointsloop[:, 1], c='r', s=20)
                plt.xlabel('X')
                plt.ylabel('Y')
                ax.axis('equal')
                plt.xlim(-125, 125)
                plt.ylim(-125, 125)
                plt.savefig('Figures/fig' + str(x) + '.png')
                p.close()
            self.transformedpoints = transpoints
        return

    def summaryplots(self):
        # plot transformed points
        fig2 = plt.figure()
        ax = fig2.gca()
        ax.scatter(self.transformedpoints[:, 0], self.transformedpoints[:, 1], c='r', s=20)
        plt.xlabel('X')
        plt.ylabel('Y')
        ax.axis('equal')
        plt.xlim(-125, 125)
        plt.ylim(-125, 125)
        plt.savefig('Figures/fig' + 'all' + '.png')
        p.show()

        # plot heat map
        heatmap, xedges, yedges = n.histogram2d(self.transformedpoints[:, 0], self.transformedpoints[:, 1], bins=30)
        extent = [xedges[0], xedges[-1], yedges[0], yedges[-1]]
        plt.clf()
        plt.imshow(heatmap.T, extent=extent, origin='lower')
        plt.savefig('Figures/fig' + 'heat' + '.png')
        p.show()
        return

    #example python transform_project.py centers --csv centers749_10.csv
    #python transform_project.py centers --csv 20210927_forcenterplotting_801_cln.csv
    #python transform_project.py centers --csv 20210927_forcenterplotting_1519_cln.csv
    #python transform_project.py centers --csv 20210927_forcenterplotting_1414_cln.csv

    def centersplot(self, namecsv):
        with open(namecsv, mode='r')as file:
            # reading the CSV file
            csvFile = csv.reader(file)
            vectors_basis = [[1, 0, 0], [0, 0, -1]]
            for row in csvFile:
                self.lab.append(row[0])
                self.Xmem.append(row[1])
                self.Ymem.append(row[2])
                self.Zmem.append(row[3])
                self.Xcen.append(row[4])
                self.Ycen.append(row[5])
                self.Zcen.append(row[6])
                self.Rot.append(row[7])
                self.Tilt.append(row[8])
                self.Psi.append(row[9])
            #convert to int
            self.Xcen = [int(float(i)) for i in self.Xcen]
            self.Ycen = [int(float(i)) for i in self.Ycen]
            self.Zcen = [int(float(i)) for i in self.Zcen]
            self.Xmem = [int(float(i)) for i in self.Xmem]
            self.Ymem = [int(float(i)) for i in self.Ymem]
            self.Zmem = [int(float(i)) for i in self.Zmem]
            self.Xcen = [int(float(i)) for i in self.Xcen]

            #normalize cen values
            for a in range(0, len(self.Xmem)):
                self.Xcen[a] = self.Xcen[a]-self.Xmem[a]
                self.Ycen[a] = self.Ycen[a]-self.Ymem[a]
                self.Zcen[a] = self.Zcen[a] - self.Zmem[a]

            #put points into array, give them plotting param
            points = n.array([self.Xcen, self.Ycen, self.Zcen], dtype=float)
            points = (n.transpose(points))
            points = Points(points)
            #put angles into array
            angles = n.array([self.Rot, self.Tilt, self.Psi], dtype=float)
            angles = n.transpose(angles)
            angles = Points(angles)
            #rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)

            # plot original points
            plot_3d(points.plotter(c='r', s=50, depthshade=False))
            plt.xlabel('X')
            plt.ylabel('Y')
            plt.xlim(-125, 125)
            plt.ylim(-125, 125)
            #plt.savefig('Figures/fig' + 'all' + '.png')
            p.show()

            # initialize loop variables
            pointsloop = points[0, 0:3]
            anglesloop = angles[0:1, 0:3]
            rot = R.from_euler('ZYZ', anglesloop[0, 0:3], degrees=True)
            rotatedpointsloop = rot.apply(pointsloop)
            allpoints = n.zeros((len(points), 3))
            transpoints = n.zeros((len(points), 2))
            # loop through transformations
            for x in range(0, len(self.Xmem)):
                pointsloop = points[x, 0:3]
                anglesloop = angles[x:x+1, 0:3]
                rot = R.from_euler('ZYZ', anglesloop[0:1, 0:3], degrees=True)
                rotatedpointsloop = rot.apply(pointsloop)

                # concatenate
                allpoints[x] = rotatedpointsloop
                transpoints[x] = transform_coordinates(rotatedpointsloop, [0, 0, 0], vectors_basis)

            allpoints = Points(allpoints)
            print(transpoints[:, 1])
            # plot rotated points
            plot_3d(allpoints.plotter(c='r', s=50, depthshade=False))
            plt.xlabel('X')
            plt.ylabel('Y')
            plt.xlim(-125, 125)
            plt.ylim(-125, 125)
            # plt.savefig('Figures/fig' + 'all' + '.png')
            p.show()
            n.savetxt("transformedpoints.csv", allpoints, delimiter=",")

            #plot transformed points
            heatmap, xedges, yedges = n.histogram2d(transpoints[:, 0], transpoints[:, 1], bins=30)
            extent = [xedges[0], xedges[-1], yedges[0], yedges[-1]]
            plt.clf()
            plt.imshow(heatmap.T, extent=extent, origin='lower')
            #plt.clim(0, 25)
            plt.colorbar()
            plt.savefig('Figures/fig' + 'heat' + '.png')
            p.show()

            fig = plt.figure()
            ax = fig.gca()
            ax.scatter(transpoints[:, 0], transpoints[:, 1], c='b', s=20)
            #plt.xlabel('X')
            #plt.ylabel('Y')
            #ax.axis('equal')
            plt.xlim(-150, 150)
            plt.ylim(-150, 150)
            ax.set_aspect('equal', adjustable='box')
            #fig.orientation = u'horizontal'
            p.show()
        return

    #example python transform_project.py calcangles --csv centers2data.csv
    def calcangles(self, namecsv):
        with open(namecsv, mode='r')as file:
            # reading the CSV file
            csvFile = csv.reader(file)
            for row in csvFile:
                self.lab.append(row[0])
                self.Xmem.append(row[1])
                self.Ymem.append(row[2])
                self.Zmem.append(row[3])
                self.Xcen.append(row[4])
                self.Ycen.append(row[5])
                self.Zcen.append(row[6])

            #convert to int
            self.Xcen = [int(float(i)) for i in self.Xcen]
            self.Ycen = [int(float(i)) for i in self.Ycen]
            self.Zcen = [int(float(i)) for i in self.Zcen]
            self.Xmem = [int(float(i)) for i in self.Xmem]
            self.Ymem = [int(float(i)) for i in self.Ymem]
            self.Zmem = [int(float(i)) for i in self.Zmem]
            self.Xcen = [int(float(i)) for i in self.Xcen]

            #normalize cen values
            for a in range(0, len(self.Xmem)):
                self.Xcen[a] = self.Xcen[a]-self.Xmem[a]
                self.Ycen[a] = self.Ycen[a]-self.Ymem[a]
                self.Zcen[a] = self.Zcen[a] - self.Zmem[a]

            #put points into array, give them plotting param
            points = n.array([self.Xcen, self.Ycen, self.Zcen], dtype=float)
            points = (n.transpose(points))
            points = Points(points)

            mems = n.array([self.Xmem, self.Ymem, self.Zmem], dtype=float)
            mems = (n.transpose(mems))
            mems = Points(mems)
        #mems = n.zeros((len(points), 3))
        vector_1 = [0, 0, 1]
        vector_2 = points
        #print(vector_1[0:2, :])
        #print(vector_2[0:2, :])
        unit_vector_1 = vector_1 / n.linalg.norm(vector_1)
        unit_vector_2 = 0
        newangs = n.zeros((len(points), 3))
        for w in range(0, len(points)):
            #print(vector_2[w])
            unit_vector_2 = vector_2[w] / n.linalg.norm(vector_2[w])
            dot_product = n.dot(unit_vector_2, unit_vector_1)
            #print(dot_product)
            angle = n.arccos(dot_product)
            crossprod = n.cross(unit_vector_2, unit_vector_1)
            axis = n.asarray(crossprod)
            #print(crossprod)
            axis = axis / math.sqrt(n.dot(axis, axis))
            r = R.from_rotvec(angle * axis)
            #print(r.as_matrix())

            newcen = r.apply(vector_2[w])
            #print(newcen)
            newangs[w, :] = r.as_euler('ZYZ', degrees=True)
        n.savetxt("neweulerangs.csv", newangs, delimiter=",")
        return

    def _get_num_lines(self, file_path):
        # https://blog.nelsonliu.me/2016/07/30/progress-bars-for-python-file-reading-with-tqdm/
        fp = open(file_path, "r+")
        buf = mmap(fp.fileno(), 0)
        lines = 0
        while buf.readline():
            lines += 1
        return (lines)
        return

    def _cast(self, val, this_type):
        if this_type is int:
            return (int(val))
        if this_type is float:
            return (float(val))
        if this_type is str:
            return (str(val))
        if this_type is bool:
            return (bool(val))
        else:
            print(val, this_type)
            raise ValueError('Invalid type.')
        return

    def load_stars(self, input_stars, verbose=True):
        try:
            assert os.path.isfile(input_stars)
            self.input_stars = [input_stars]
        except:
            if all([os.path.isfile(i_s) for i_s in input_stars]):
                self.input_stars = sorted(input_stars)
            else:
                raise
        if verbose:
            print('Accepted the following .star files:\n{}'.format('\n'.join(self.input_stars)))
        return

    def rename_stars(self, star_dir):
        ...

    def find_stars(self, star_dir, remove_ct=True, verbose=True):
        assert os.path.isdir(star_dir)
        self.input_stars = sorted(glob(os.path.join(star_dir, '*.star')))
        if remove_ct:
            new_stars = []
            for star in self.input_stars:
                if '_ct' in star:
                    star_path, new_star = os.path.split(star)
                    new_star = '_'.join([s for s in star.split('_') if 'ct' not in s])
                    new_star = os.path.join(star_path, new_star)
                    os.rename(star, new_star)
                    new_stars.append(new_star)
                else:
                    new_stars.append(star)
            self.input_stars = sorted(new_stars)
        if verbose:
            print('Found the following .star files:\n{}'.format('\n'.join(self.input_stars)))
        return

    def read_stars(self, mode=None, verbose=False):
        if len(self.input_stars) > 1:  # More than one input star file
            self.input_stars = sorted(self.input_stars)
            multi_star = True
        else:  # Just one input star file
            multi_star = False
        general_blocks = []  # These are blocks that don't update per iteration and have general metadata
        for this_star in tqdm(self.input_stars, desc='Reading .star files', leave=False):  # Iterate over star files
            with open(this_star, 'r') as f_i:
                star_name = os.path.splitext(os.path.split(this_star)[1])[0]
                if multi_star:  # Try to get the iteration index for this star file
                    try:
                        star_it = int([it for it in star_name.split('_') if 'it' in it][0][2:])
                    except:
                        star_it = -1
                else:
                    star_it = None
                self.data.update({star_name: {}})  # New dictionary for this star file
                loop = False  # Are we in a data loop?
                this_block_name = None  # Name of current data block
                prev_line_header = False  # Last line was a header?
                prev_line_data = False  # Last line was data?
                if verbose:
                    print(star_name)
                for line in tqdm(f_i, desc='{}.star'.format(star_name), total=self._get_num_lines(this_star),
                                 leave=False):  # Iterate over lines in this star file
                    val = line.strip()
                    if not val or val[
                        0] == '#':  # If it's a blank line or comment... note that this will fail for some files which end without a blank line
                        if prev_line_data:
                            if verbose:
                                print('\tBuilding data table for {} from {}.star.\r'.format(this_block_name, star_name),
                                      end='')
                            if this_block_name not in self.dataframes.keys():
                                self.dataframes[this_block_name] = {}
                            self.dataframes[this_block_name].update(
                                {
                                    star_name: {
                                        'idx': star_it,
                                        'df': pd.DataFrame(this_block_data,
                                                           columns=list(self.data[star_name][this_block_name].keys()))
                                    }
                                }
                            )
                            self.dataframes[this_block_name][star_name]['df'] = \
                            self.dataframes[this_block_name][star_name]['df'].astype(
                                {k: v['type'] for k, v in self.data[star_name][this_block_name].items()}
                            )
                            del (this_block_data)
                            if mode == 'class3d-fast' and 'data_model_classes' in self.dataframes.keys():
                                break
                        prev_line_data = False
                        loop = False
                        continue

                    if val.startswith('loop_'):  # new block
                        loop = True
                        continue
                    val = val.split()
                    if not loop and len(val) == 1:  # block name
                        val = val[0]
                        if any([l in val for l in self.labels.keys()]):
                            this_block_name = val
                            for label in self.labels.keys():
                                if label in this_block_name:
                                    self.data[star_name].update({this_block_name: deepcopy(self.labels[label])})
                                    break
                            assert (self.data[star_name][this_block_name])
                            if verbose:
                                print('\t{}'.format(this_block_name))
                        else:
                            raise ValueError('{} not found in label lookup dict!'.format(val))
                    elif val[0].startswith('_'):  # loop column header
                        assert (this_block_name is not None)
                        this_label, this_entry = [v.strip() for v in val]
                        this_label = this_label[1:]
                        if verbose:
                            print('\t\t{}: {}'.format(this_label, this_entry))
                        self.data[star_name][this_block_name][this_label]['found'] = True
                        if 'col' in self.data[star_name][this_block_name][this_label]:
                            self.data[star_name][this_block_name][this_label]['col'] = int(this_entry.strip('#')) - 1
                        else:
                            self.data[star_name][this_block_name][this_label]['val'] = self._cast(this_entry,
                                                                                                  self.data[star_name][
                                                                                                      this_block_name][
                                                                                                      this_label][
                                                                                                      'type'])
                            if this_block_name not in general_blocks:
                                general_blocks.append(this_block_name)
                        prev_line_header = True
                        prev_line_data = False
                    elif loop and not val[0].startswith('_'):  # data
                        if prev_line_header:
                            prev_line_header = False
                            this_block_data = []
                        this_block_data.append(val)
                        prev_line_data = True

        for this_block in tqdm(self.dataframes.values(), desc='Concatenating frames',
                               total=len(self.dataframes.values()),
                               leave=False):  # Join individual data frames into multi index
            this_block['cat'] = pd.concat(
                {this_block[k]['idx']: this_block[k]['df'] for k in this_block.keys()}
            )
            this_block['cat'].index.names = ('iteration', 'entry')
        for this_block_name in general_blocks:
            assert (this_block_name not in self.dataframes.keys())
            self.dataframes[this_block_name] = {}
            for star_name in self.data.keys():
                if multi_star:
                    try:
                        star_it = int([it for it in star_name.split('_') if 'it' in it][0][2:])
                    except:
                        star_it = -1
                else:
                    star_it = None
                self.dataframes[this_block_name].update(
                    {
                        star_name: {
                            'idx': star_it,
                            'df': pd.DataFrame.from_dict(
                                {k: [v['val']] for k, v in self.data[star_name][this_block_name].items() if v['found']}
                            )
                        }
                    }
                )
            self.dataframes[this_block_name]['cat'] = pd.concat(
                {self.dataframes[this_block_name][star_name]['idx']: self.dataframes[this_block_name][star_name]['df']
                 for star_name in self.dataframes[this_block_name].keys()}
            )
        return

    def save(self, out_pkl):
        with open(out_pkl, 'wb') as p_o:
            pickle.dump(self, p_o)
        return

    def reload(self, in_pkl):
        with open(in_pkl, 'rb') as p_i:
            with pickle.load(p_i) as stuff:
                self.input_stars = stuff.input_stars
                self.data = stuff.data
                self.dataframes = stuff.dataframes
                self.labels = stuff.labels
        return
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='transforming coordinates using euler angles')
    parser.add_argument('mode',
                        choices=['plot', 'summary', 'centers', 'calcangles'],
                        default=None, help='Operation mode...')
    # parser.add_argument('--star_dir', type=str, default=os.getcwd(), help='A directory with .star files.')
    parser.add_argument('--csv', type=str, default=None,
                         help='csv file with coord index, x,y,z coord, and rot, tilt, psi angles.')
    parser.add_argument('--partcount', type=int, help='your number of particles.')
    parser.add_argument('--numtodisplay', type=int, help='number of part to display, from end')
    parser.add_argument('--star_dir', type=str, default=os.getcwd(), help='A directory with .star files.')
    parser.add_argument('--stars', nargs='*', type=str, default=None,
                        help='One or more .star files; star_dir will be ignored if this is provided.')
    args = parser.parse_args()
    t = transformall()
    if args.csv is None:
        print('Please add csv file using --csv [filepath]')
    if args.stars is None:
        #print('hi')
        t.find_stars(args.star_dir, verbose=True)
    elif args.stars is not None:
        t.load_stars(args.stars, verbose=False)
    #t.read_stars(mode=args.mode, verbose=False)
    if args.mode.startswith('plot'):
        t.transformandplot(args.csv, args.partcount, args.numtodisplay)
        t.transformnoplot(args.csv, args.partcount)
        t.summaryplots()
    elif args.mode.startswith('summary'):
        t.transformnoplot(args.csv, args.partcount)
        t.summaryplots()
    elif args.mode.startswith('centers'):
        t.centersplot(args.csv)
    elif args.mode.startswith('calcangles'):
        t.calcangles(args.csv)
