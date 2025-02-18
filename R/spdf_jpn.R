#' Simple features for prefecture area polygon
#'
#' @description Prefecture polygon data.
#' @details Collect unit of prefecture simple feature data.frame objects..
#' If download argument is *TRUE*, download administrative area data from
#' the National Land Numeral Information Download Service (for law data).
#' @param pref_code jis code from 1 to 47
#' @param admin_name prefecture names (string)
#' @param district logical (default *TRUE*)
#' @param download logical (default *FALSE*). IF *TRUE*, return raw data.
#' @param drop_sinkyokyoku if *TRUE*, drop sichyo_sinkyokyoku variable
#' (default *TRUE*)
#' @importFrom dplyr matches mutate select
#' @examples
#' \dontrun{
#' jpn_pref(pref_code = 33, district = FALSE)
#' jpn_pref(pref_code = 14, district = TRUE)
#' }
#'
#' @export
jpn_pref <- function(pref_code,
                     admin_name,
                     district         = TRUE,
                     download         = FALSE,
                     drop_sinkyokyoku = TRUE) {
  city_code <- city_name <- city_name_ <- city_name_full <- NULL # nolint
  . <- geometry <- pref_name <- NULL # nolint

    if (missing(admin_name)) {
      pref_code <- collect_prefcode(code = pref_code)
    } else if (missing(pref_code)) {
      pref_code <- collect_prefcode(admin_name = admin_name)
    }

  if (download == FALSE) {
    d <- readRDS(system.file(paste0("extdata/ksj_n03/pref_", pref_code, ".rds"),
                             package = "jpndistrict")) %>%
      decode.sfencoded()
  } else {
    d <-
      read_ksj_cityarea(code = as.numeric(pref_code)) %>%  # nocov
      dplyr::mutate(pref_code = as.character(pref_code),
                    city_name_full = purrr::pmap_chr(.,
                                                     ~ cityname_reform(..4))) %>% # nolint
      dplyr::select(pref_code, pref_name,
                    city_code, city = city_name_full,
                    city_name_, city_name, geometry)
  }

  if (drop_sinkyokyoku == TRUE) {
    d <- dplyr::select(d, -dplyr::matches("sichyo_sinkyokyoku"))
  }

  if (district == TRUE) {
    res <- d
  } else {
    res <- raw_bind_cityareas(d) %>%
      dplyr::mutate(pref_code = as.character(pref_code))
  }
  res %>%
    tweak_sf_output()
}


#' Simple features for city area polygons
#'
#' @description City area polygon data. When an administrative name
#' (jis_code_city) or code (jis_code_city) is specified as an argument,
#' the target city data is extracted. If neither is given,
#' it becomes the data of the target prefecture.
#' @importFrom dplyr filter
#' @inheritParams code_validate
#' @param admin_name administration name
#' @examples
#' jpn_cities(jis_code = "08",
#'   admin_name = intToUtf8(c(12388, 12367, 12400, 24066)))
#'
#' jpn_cities(jis_code = 33103)
#' jpn_cities(jis_code = "33103")
#' jpn_cities(jis_code = c(33103, 33104, 33205))
#' jpn_cities(jis_code = c(33103, 34107))
#' @export
jpn_cities <- function(jis_code, admin_name) {

  city_code <- city <- geometry <- NULL

  jis_code_q <- rlang::enquo(jis_code)
  admin_name_q <- rlang::enquo(admin_name)

  d <-
    jis_code %>%
    purrr::map_chr(~ substr(.x, 1, 2)) %>%
    unique() %>%
    purrr::map(~ jpn_pref(pref_code = .x, district = TRUE)) %>%
    purrr::reduce(rbind) %>%
    dplyr::select(-seq_len(2)) %>%
    dplyr::select(city_code, city, geometry)

  if (nchar(jis_code[1]) > 3) {
    if (missing(admin_name)) {
      d <-
        dplyr::filter(d, city_code %in% !!jis_code_q)
    }
  }
  if (!missing(admin_name)) {
      d <-
        dplyr::filter(d, city %in% !!admin_name_q)
    }
  d %>%
    tweak_sf_output()
}

#' Simple features for administration office points
#'
#' @description Name and geolocations for administration offices in prefecture.
#' @inheritParams code_validate
#' @importFrom rlang enquo
#' @importFrom dplyr filter
#' @importFrom purrr map reduce
#' @return data.frame. contains follow columns jis_code,
#' type, name, address, longitude and latitude.
#' @examples
#' \dontrun{
#' jpn_admins(jis_code = 17)
#' }
#' @export
jpn_admins <- function(jis_code) {

    jis_code_q <- rlang::enquo(jis_code)

    d <- jis_code %>%
      purrr::map_chr(~ substr(.x, 1, 2)) %>%
      unique() %>%
      purrr::map(~ read_ksj_p34(pref_code = as.numeric(.x))) %>%
      purrr::reduce(rbind)

    if (nchar(jis_code[1]) > 2) {
      res <- dplyr::filter(d, jis_code %in% !!jis_code_q) # nocov
    } else {
      res <- d
    }

  return(res)

}
