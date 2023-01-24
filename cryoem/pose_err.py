import argparse
import numpy as np

def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pose1", help="Pickle input")
    parser.add_argument("pose2", help="Pickle input")
    return parser

def main(args):
    pose_1 = np.load(args.pose1, allow_pickle = True)
    pose_2 = np.load(args.pose2, allow_pickle = True)

    rotmat_1, trans_1 = pose_1[0], pose_1[1]
    rotmat_2, trans_2 = pose_2[0], pose_2[1]

    rotmat_err = np.linalg.norm(rotmat_1 - rotmat_2, ord = 'fro', axis = (1, 2))
    trans_err = np.linalg.norm(trans_1 - trans_2, axis = 1)

    rotmat_err_mean, rotmat_err_median = np.mean(rotmat_err), np.median(rotmat_err)
    trans_err_mean, trans_err_median = np.mean(trans_err), np.median(trans_err)

    result = f"""
    Pose error             mean / median
    # Rotation error:    {rotmat_err_mean:.4f} / {rotmat_err_median:.4f}
    # Translation error: {trans_err_mean:.4f} / {trans_err_median:.4f}
    """

    print(result)

if __name__ == "__main__":
    main(parse_args().parse_args())