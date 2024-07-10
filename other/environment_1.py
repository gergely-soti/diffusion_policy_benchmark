import numpy as np
import robosuite as suite
from robosuite.utils.camera_utils import CameraMover
import cv2
from manipulation_tasks.transform import Affine
from robosuite.utils.mjcf_utils import find_elements


class RandomCameraFactory:
    def __init__(self,
                 bullet_client,
                 n_cameras=3,
                 min_azimuth=-np.pi + np.pi / 6,
                 max_azimuth=np.pi - np.pi / 6,
                 min_polar=np.pi / 6,
                 max_polar=np.pi / 3,
                 radius=0.8,
                 t_center=np.array([0.2, 0.0, 0.9605]),
                 resolution=(480, 640),
                 intrinsics=(450, 0, 320, 0, 450, 240, 0, 0, 1),
                 depth_range=(0.01, 10.0)):
        self.bullet_client = bullet_client
        self.n_cameras = n_cameras

        self.min_azimuth = min_azimuth
        self.max_azimuth = max_azimuth
        self.min_polar = min_polar
        self.max_polar = max_polar
        self.radius = radius
        self.t_center = t_center
        self.resolution = resolution
        self.intrinsics = intrinsics
        self.depth_range = depth_range

    def create_camera(self):
        azimuth = np.random.uniform(self.min_azimuth, self.max_azimuth)
        cos_polar = np.random.uniform(np.cos(self.max_polar), np.cos(self.min_polar))
        polar = np.arccos(cos_polar)
        pose = Affine.polar(azimuth, polar, self.radius, self.t_center)
        return BulletCamera(self.bullet_client, pose.matrix, self.resolution, self.intrinsics, self.depth_range)

    @property
    def cameras(self):
        cameras = [self.create_camera() for _ in range(self.n_cameras)]
        return cameras


if __name__ == "__main__":
    CAMERA_NAME = "frontview"
    n_cameras = 3
    CAMERA_NAMES = [f"camera_{i}" for i in range(n_cameras)]
    # create environment instance
    env = suite.make(
        env_name="Lift",  # try with other tasks like "Stack" and "Door"
        robots="Panda",  # try with other robots like "Sawyer" and "Jaco"
        has_renderer=True,
        has_offscreen_renderer=True,
        use_camera_obs=True,
        render_camera=CAMERA_NAME,
        camera_names=CAMERA_NAMES,
    )

    # reset the environment
    env.reset()
    # camera_mover = CameraMover(
    #     env=env,
    #     camera=CAMERA_NAME,
    # )
    # camera_id = env.sim.model.camera_name2id(CAMERA_NAME)
    # env.viewer.set_camera(camera_id=camera_id)
    # camera_pos, camera_quat = camera_mover.get_camera_pose()
    # camera_mover.set_camera_pose(pos=camera_pos, quat=camera_quat)

    for i in range(1000):
        action = np.random.randn(env.robots[0].dof)  # sample random action
        obs, reward, done, info = env.step(action)  # take action in the environment
        env.render()  # render on display
        # camera_pos[2] += 0.001
        # camera_mover.set_camera_pose(pos=camera_pos, quat=camera_quat)
        for camera_name in CAMERA_NAMES:
            camera_image_name = f"{camera_name}_image"
            camera_image = obs[camera_image_name]
            print(f"Camera: {camera_name} Image Shape: {camera_image.shape}")
            # cv2.imshow(camera_name, camera_image)
            # cv2.waitKey(1)

            camera = find_elements(root=env.model.mujoco_arena.worldbody, tags="camera", attribs={"name": camera_name},
                                   return_first=True)
            print(dir(camera))
            print(camera.keys())
        # # Render the custom camera
        # custom_camera_image = render_custom_camera('custom_camera')
        #
        # # Display or process the custom camera image as needed
        # cv2.imshow("Custom Camera", custom_camera_image)
        # cv2.waitKey(1)

    # Make sure to properly close the environment
    env.close()
