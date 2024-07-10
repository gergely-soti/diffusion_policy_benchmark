import numpy as np
import robosuite as suite
from robosuite.utils.camera_utils import CameraMover
import cv2

CAMERA_NAME = "frontview"
n_cameras = 25
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
    print(obs.keys())
    for camera_name in CAMERA_NAMES:
        camera_image_name = f"{camera_name}_image"
        camera_image = obs[camera_image_name]
        cv2.imshow(camera_name, camera_image)
        cv2.waitKey(1)

    # # Render the custom camera
    # custom_camera_image = render_custom_camera('custom_camera')
    #
    # # Display or process the custom camera image as needed
    # cv2.imshow("Custom Camera", custom_camera_image)
    # cv2.waitKey(1)

# Make sure to properly close the environment
env.close()
