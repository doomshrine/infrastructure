import argparse
import os
from jinja2 import Environment, FileSystemLoader


TEMPLATE_DIR = "templates"
GENERATED_DIR = "generated"


def generate(config: dict):
    # create the jinja2 environment
    env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
    # get the template
    templates = env.list_templates()

    for t in templates:
        if t.endswith(".j2"):
            template = env.get_template(t)
            # render the template
            output = template.render(config)
            # write the output to a file
            with open(os.path.join(GENERATED_DIR, t[:-3]), "w") as f:
                f.write(output)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("platform", help="Name of platform to generate for")
    return parser.parse_args()


def main():
    args = parse_args()
    generate({"platform": args.platform})


if __name__ == "__main__":
    main()
