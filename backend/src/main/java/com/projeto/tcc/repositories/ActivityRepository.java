package com.projeto.tcc.repositories;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.projeto.tcc.dto.ActivityTrendDTO;
import com.projeto.tcc.entities.Activity;
import com.projeto.tcc.entities.ActivityType;
import com.projeto.tcc.entities.User;

public interface ActivityRepository extends JpaRepository<Activity, Long> {

    // Build upon existing Activity queries
    List<Activity> findByUserAndTimestampBetween(User user, LocalDateTime start, LocalDateTime end);

    @Query("SELECT a FROM Activity a WHERE a.user = :user AND a.type = :type AND a.timestamp BETWEEN :start AND :end")
    List<Activity> findByUserAndTypeAndPeriod(@Param("user") User user,
                                             @Param("type") ActivityType type,
                                             @Param("start") LocalDateTime start,
                                             @Param("end") LocalDateTime end);

    // Enhanced statistical queries
    @Query("SELECT AVG(a.value) FROM Activity a WHERE a.user = :user AND a.type = :type")
    Double findAverageValueByUserAndType(@Param("user") User user, @Param("type") ActivityType type);

    @Query("SELECT new com.projeto.tcc.dto.ActivityTrendDTO(" +
            "CAST(a.timestamp AS date), AVG(a.value), COUNT(a)) " +
            "FROM Activity a " +
            "WHERE a.user = :user AND a.timestamp BETWEEN :start AND :end " +
            "GROUP BY CAST(a.timestamp AS date) " +
            "ORDER BY CAST(a.timestamp AS date)")
     List<ActivityTrendDTO> findDailyTrends(
             @Param("user") User user,
             @Param("start") LocalDateTime start,
             @Param("end") LocalDateTime end
     );
}
