
// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ODT.Academy.DisplayP3_dim.a1.0.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - DisplayP3</ACESuserName>

// 
// Output Device Transform - DisplayP3
//

//
// Summary :
//  This transform is intended for mapping OCES onto a display calibrated using
//  the DCI P3 primaries, a D65 white point, and the sRGB transfer function as
//  given by https://developer.apple.com/documentation/coregraphics/cgcolorspace/1408916-displayp3
//
//  There is no display standard associated with the color space thus, for
//  consistency, 100 cd/m^2 is recommended as the peak display luminance.
//  The assumed observer adapted white is D65, and the viewing environment is
//  that of a dim surround.
//
// Device Primaries : 
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.68      0.32
//              Green:        0.265     0.69
//              Blue:         0.15      0.06
//              White:        0.3127    0.329     100 cd/m^2
//
// Display EOTF :
//  The sRGB piece-wise transfer function specified in IEC 61966-2-1:1999 (sRGB).
//



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = P3D65_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);

// NOTE: The EOTF is *NOT* gamma 2.4, it follows IEC 61966-2-1:1999
const float DISPGAMMA = 2.4; 
const float OFFSET = 0.055;


void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut
)
{
    float oces[3] = { rIn, gIn, bIn};

    // OCES to RGB rendering space
    float rgbPre[3] = mult_f3_f44( oces, AP0_2_AP1_MAT);

    // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0]);
    rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1]);
    rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2]);

    // Scale luminance to linear code value
    float linearCV[3];
    linearCV[0] = Y_2_linCV( rgbPost[0], CINEMA_WHITE, CINEMA_BLACK);
    linearCV[1] = Y_2_linCV( rgbPost[1], CINEMA_WHITE, CINEMA_BLACK);
    linearCV[2] = Y_2_linCV( rgbPost[2], CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround( linearCV);

    // Apply desaturation to compensate for luminance difference
    linearCV = mult_f3_f33( linearCV, ODT_SAT_MAT);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, AP1_2_XYZ_MAT);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Handle out-of-gamut values
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    linearCV = clamp_f3( linearCV, 0., 1.);

    // Encode linear code values with transfer function
    float outputCV[3];
    // moncurve_r with gamma of 2.4 and offset of 0.055 matches the EOTF found in IEC 61966-2-1:1999 (sRGB)
    outputCV[0] = moncurve_r( linearCV[0], DISPGAMMA, OFFSET);
    outputCV[1] = moncurve_r( linearCV[1], DISPGAMMA, OFFSET);
    outputCV[2] = moncurve_r( linearCV[2], DISPGAMMA, OFFSET);

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}