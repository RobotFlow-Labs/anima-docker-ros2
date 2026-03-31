from setuptools import find_packages, setup


package_name = "robotflowlabs_anima_pubsub"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{package_name}"]),
        (f"share/{package_name}", ["package.xml"]),
        (f"share/{package_name}/launch", ["launch/pubsub_demo.launch.py"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="RobotFlowLabs",
    maintainer_email="opensource@robotflowlabs.com",
    description="Starter ROS 2 pub/sub package for RobotFlowLabs ANIMA.",
    license="Apache-2.0",
    tests_require=["pytest"],
    entry_points={
        "console_scripts": [
            "talker = robotflowlabs_anima_pubsub.talker:main",
            "listener = robotflowlabs_anima_pubsub.listener:main",
        ],
    },
)
