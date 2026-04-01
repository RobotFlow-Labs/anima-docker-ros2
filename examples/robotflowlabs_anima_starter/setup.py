from setuptools import setup

package_name = "robotflowlabs_anima_starter"

setup(
    name=package_name,
    version="0.1.0",
    packages=[package_name],
    data_files=[
        (
            "share/ament_index/resource_index/packages",
            [f"resource/{package_name}"],
        ),
        (f"share/{package_name}", ["package.xml", "README.md"]),
        (f"share/{package_name}/launch", ["launch/starter_demo.launch.py"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="RobotFlowLabs",
    maintainer_email="opensource@robotflowlabs.com",
    description="Flagship ANIMA starter showcase package.",
    license="Apache-2.0",
    tests_require=["pytest"],
    entry_points={
        "console_scripts": [],
    },
)
